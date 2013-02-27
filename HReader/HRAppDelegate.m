//
//  HRAppDelegate.m
//  HReader
//
//  Created by Marshall Huss on 11/14/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <objc/message.h>
#import <sys/stat.h>

#import "CMDEncryptedSQLiteStore.h"

#import "HRAppDelegate.h"
#import "HRAPIClient.h"
#import "HRRHExLoginViewController.h"
#import "HRPeopleSetupViewController.h"
#import "HRCryptoManager.h"
#import "HRSplashScreenViewController.h"
#import "HRHIPPAMessageViewController.h"
#import "HRAppletConfigurationViewController.h"
#import "HRCryptoManager.h"
#import "HRMPatient.h"

#import <SecurityCheck/SecurityCheck.h>
#import <AppPassword/IMSPasswordViewController.h>
#import <SecureFoundation/SecureFoundation.h>

@interface HRAppDelegate() 

    //-----------------------------------
    // Callback block from SecurityCheck
    //-----------------------------------
    typedef void (^cbBlock) (void);

    - (void) weHaveAProblem;

@end


@implementation HRAppDelegate {
    NSUInteger passcodeAttempts;
    UINavigationController *securityNavigationController;
    NSPersistentStore *persistentStore;
}

#pragma mark - class methods

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    static NSPersistentStoreCoordinator *coordinator = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"hReader" withExtension:@"momd"];
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    });
    return coordinator;
}

+ (NSManagedObjectContext *)rootManagedObjectContext {
    static NSManagedObjectContext *context = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [context setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    });
    return context;
}

+ (NSManagedObjectContext *)managedObjectContext {
    static NSManagedObjectContext *context = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [context setParentContext:[self rootManagedObjectContext]];
    });
    return context;
}

#pragma mark - object methods

- (void)addPersistentStoreIfNeeded {
    if (persistentStore == nil) {
        NSError *error = nil;
        NSPersistentStoreCoordinator *coordinator = [HRAppDelegate persistentStoreCoordinator];
        
        // store configuration
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *applicationSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
        [fileManager createDirectoryAtURL:applicationSupportURL withIntermediateDirectories:NO attributes:nil error:nil];
        NSURL *databaseURL = [applicationSupportURL URLByAppendingPathComponent:@"database.sqlite3.2"];
        NSDictionary *options = @{
            NSPersistentStoreFileProtectionKey : NSFileProtectionComplete,
            NSMigratePersistentStoresAutomaticallyOption : [NSNumber numberWithBool:YES],
            NSInferMappingModelAutomaticallyOption : [NSNumber numberWithBool:YES]
//            NSMigratePersistentStoresAutomaticallyOption : @YES,
//            NSInferMappingModelAutomaticallyOption : @YES
        };
        
        // add store
        persistentStore = HRCryptoManagerAddEncryptedStoreToCoordinator(coordinator,
                                                                        nil,
                                                                        databaseURL,
                                                                        options,
                                                                        &error);
        NSAssert(persistentStore, @"Unable to add persistent store\n%@", error);
        
    }
}

- (void)performLaunchSteps {
    
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
    
    //-----------------------------------
    // call back to weHaveAProblem
    //-----------------------------------
    cbBlock chkCallback  = ^{
        
        __weak id weakSelf = self;
        
        if (weakSelf) [weakSelf weHaveAProblem];
    };
    
    //-----------------------------------
    // jailbreak detection
    //-----------------------------------
    checkFork(chkCallback);
    checkFiles(chkCallback);
    checkLinks(chkCallback);
    
#endif
    // check for hippa message
    if (![HRHIPPAMessageViewController hasAcceptedHIPPAMessage]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"InitialSetup_iPad" bundle:nil];
        HRHIPPAMessageViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"HIPPAViewController"];
        controller.navigationItem.hidesBackButton = YES;
        controller.target = self;
        controller.action = _cmd;
        UINavigationController *navigation = (id)self.window.rootViewController;
        [navigation popToRootViewControllerAnimated:NO];
        [navigation pushViewController:controller animated:YES];
    }
    
    // check for passcode
    else if (!HRCryptoManagerHasPasscode() || !HRCryptoManagerHasSecurityQuestions()) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"InitialSetup_iPad" bundle:nil];
        IMSPasswordViewController *password = [storyboard instantiateViewControllerWithIdentifier:@"CreatePasscodeViewController"];
        password.title = @"Set Password";
        password.target = self;
        password.action = @selector(createInitialPasscode::);
        password.navigationItem.hidesBackButton = YES;
        [(id)self.window.rootViewController pushViewController:password animated:YES];
        [[[UIAlertView alloc]
          initWithTitle:@"Welcome"
          message:@"Before you start using hReader, you must set a passcode and create security questions."
          delegate:nil
          cancelButtonTitle:@"OK"
          otherButtonTitles:nil]
         show];
    }
    
    // unlocked
    else if (HRCryptoManagerIsUnlocked()) {
        NSArray *hosts = [HRAPIClient hosts];
        UIViewController *controller = [(id)self.window.rootViewController topViewController];
        
        // load persistent store
        [self addPersistentStoreIfNeeded];
        
        // check for accounts
        if ([hosts count] == 0) {
            HRAPIClient *client = [HRAPIClient clientWithHost:@"growing-spring-4857.herokuapp.com"];
            HRRHExLoginViewController *controller = [HRRHExLoginViewController loginViewControllerForClient:client];
            controller.navigationItem.hidesBackButton = YES;
            controller.target = self;
            controller.action = @selector(initialLoginDidSucceed:);
            [(id)self.window.rootViewController pushViewController:controller animated:YES];
        }
        
        // carry on
        else {
            
            // update local data
            NSString *host = [hosts lastObject];
            [[HRAPIClient clientWithHost:host] patientFeed:nil];
            [HRMPatient performSync];
            // push storyboard if we need to
            if ([controller isKindOfClass:[HRSplashScreenViewController class]] ||
                [controller isKindOfClass:[HRHIPPAMessageViewController class]]) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"InitialSetup_iPad" bundle:nil];
                id controller = [storyboard instantiateViewControllerWithIdentifier:@"PeopleSetupViewController"];
                [[controller navigationItem] setHidesBackButton:YES];
                [(id)self.window.rootViewController pushViewController:controller animated:YES];
            }
            
        }
        
    }
    
    // locked
    else {
        [self presentPasscodeVerificationController:YES];
    }
    
}

#pragma mark - notifications

- (void)managedObjectContextDidSave:(NSNotification *)notification {
    
    // get contexts
    NSManagedObjectContext *rootContext = [HRAppDelegate rootManagedObjectContext];
    NSManagedObjectContext *mainContext = [HRAppDelegate managedObjectContext];
    NSManagedObjectContext *savingContext = [notification object];
    
    // main -> root
    if (savingContext == mainContext) {
        [rootContext performBlock:^{
            NSError *error = nil;
            if (![rootContext save:&error]) { HRDebugLog(@"Unable to save root context: %@", error); }
        }];
    }
    
    // child -> main
    else if ([savingContext parentContext] == mainContext) {
        [mainContext performBlock:^{
            NSError *error = nil;
            if (![mainContext save:&error]) { HRDebugLog(@"Unable to save main context: %@", error); }
        }];
    }
    
}

#pragma mark - application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
    //--------------------------------
    // do not allow debuggers
    //--------------------------------
    dbgStop;
    
    //--------------------------------------------------------------------------
    // check for the presence of a debugger, call weHaveAProblem if there is one
    //--------------------------------------------------------------------------
    cbBlock dbChkCallback = ^{
        
        __weak id weakSelf = self;
        
        if (weakSelf) [weakSelf weHaveAProblem];
    };
    
    dbgCheck(dbChkCallback);
    
#endif
    
    // notifications
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(managedObjectContextDidSave:)
     name:NSManagedObjectContextDidSaveNotification
     object:nil];
    
    // launch steps
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [self performLaunchSteps];
    });
    
    // return
    return YES;
    
}

//--------------------------------------------------------------------
// if a debugger is attched to the app then this method will be called
//--------------------------------------------------------------------
- (void) weHaveAProblem {
        
    exit(0);
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // remove persistent store
//    NSPersistentStoreCoordinator *coordinator = [HRAppDelegate persistentStoreCoordinator];
//    if ([coordinator removePersistentStore:persistentStore error:nil]) {
//        persistentStore = nil;
//        [[HRAppDelegate managedObjectContext] reset];
//    }
    
    // destroy encryption keys
    HRCryptoManagerPurge();
    
    // reset interface
    if (!HRCryptoManagerHasPasscode() || !HRCryptoManagerHasSecurityQuestions()) {
        [(id)self.window.rootViewController popToRootViewControllerAnimated:NO];
    }
    [securityNavigationController dismissViewControllerAnimated:NO completion:nil];
    securityNavigationController = nil;
    [self presentPasscodeVerificationController:NO];
    
}

#pragma mark - security scenario one

/*
 
 Methods used when setting the security information on first launch.
 
 */

- (void)createInitialPasscode :(IMSPasswordViewController *)controller :(NSString *)passcode {
    HRCryptoManagerStoreTemporaryPasscode(passcode);
    HRSecurityQuestionsViewController *questions = [controller.storyboard instantiateViewControllerWithIdentifier:@"SecurityQuestionsController"];
    questions.navigationItem.hidesBackButton = YES;
    questions.mode = HRSecurityQuestionsViewControllerModeCreate;
    questions.delegate = self;
    questions.title = @"Security Questions";
    questions.action = @selector(createInitialSecurityQuestions:::);
    [controller.navigationController pushViewController:questions animated:YES];
}

- (void)createInitialSecurityQuestions :(HRSecurityQuestionsViewController *)controller :(NSArray *)questions :(NSArray *)answers {
    HRCryptoManagerStoreTemporarySecurityQuestionsAndAnswers(questions, answers);
    HRCryptoManagerFinalize();
    [self performLaunchSteps];
}

#pragma mark - security scenario two

/*
 
 Methods used when verifying the user's passcode on launch.
 
 */

- (void)presentPasscodeVerificationController:(BOOL)animated {
    NSAssert(!securityNavigationController, @"You cannot present two passcode verification controllers");
    passcodeAttempts = 0;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"InitialSetup_iPad" bundle:nil];
    IMSPasswordViewController *password = [storyboard instantiateViewControllerWithIdentifier:@"VerifyPasscodeViewController"];
    password.target = self;
    password.action = @selector(verifyPasscodeOnLaunch::);
    password.title = @"Enter Password";
    securityNavigationController = [[UINavigationController alloc] initWithRootViewController:password];
    UIViewController *controller = self.window.rootViewController;
    while (YES) {
        UIViewController *presented = controller.presentedViewController;
        if (presented) { controller = presented; }
        else { break; }
    }
    [controller presentViewController:securityNavigationController animated:animated completion:nil];
}

- (BOOL)verifyPasscodeOnLaunch :(IMSPasswordViewController *)controller :(NSString *)passcode {
    if (HRCryptoManagerUnlockWithPasscode(passcode)) {
        [self addPersistentStoreIfNeeded];
        [controller dismissViewControllerAnimated:YES completion:^{
            securityNavigationController = nil;
            [self performLaunchSteps];
        }];
        return YES;
    }
    else {
        if (++passcodeAttempts > 2) {
            controller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                                           initWithTitle:@"Reset Passcode" 
                                                           style:UIBarButtonItemStyleDone 
                                                           target:self 
                                                           action:@selector(resetPasscodeWithSecurityQuestions)];
        }
        return NO;
    }
}

- (void)resetPasscodeWithSecurityQuestions {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"InitialSetup_iPad" bundle:nil];
    HRSecurityQuestionsViewController *questions = [storyboard instantiateViewControllerWithIdentifier:@"SecurityQuestionsController"];
    questions.navigationItem.hidesBackButton = YES;
    questions.mode = HRSecurityQuestionsViewControllerModeVerify;
    questions.delegate = self;
    questions.title = @"Security Questions";
    questions.action = @selector(resetPasscodeWithSecurityQuestions:::);
    [securityNavigationController pushViewController:questions animated:YES];
}

- (void)resetPasscodeWithSecurityQuestions :(HRSecurityQuestionsViewController *)controller :(NSArray *)questions :(NSArray *)answers {
    if (HRCryptoManagerUnlockWithAnswersForSecurityQuestions(answers)) {
        IMSPasswordViewController *password = [controller.storyboard instantiateViewControllerWithIdentifier:@"CreatePasscodeViewController"];
        password.target = self;
        password.action = @selector(resetPasscode::);
        password.title = @"Enter Password";
        password.navigationItem.hidesBackButton = YES;
        [controller.navigationController pushViewController:password animated:YES];
    }
    else {
        [[[UIAlertView alloc]
          initWithTitle:@"The answers you provided are not correct."
          message:nil
          delegate:nil
          cancelButtonTitle:@"OK"
          otherButtonTitles:nil]
         show];
    }
}

- (void)resetPasscode :(IMSPasswordViewController *)controller :(NSString *)passcode {
    HRCryptoManagerUpdatePasscode(passcode);
    [controller dismissViewControllerAnimated:YES completion:^{
        [self performLaunchSteps];
    }];
}

#pragma mark - security scenario three

/*
 
 Methods used when changing the passcode at the request of the user.
 
 */

- (BOOL)verifyPasscodeOnPasscodeChange :(IMSPasswordViewController *)controller :(NSString *)passcode {
    if (HRCryptoManagerUnlockWithPasscode(passcode)) {
        IMSPasswordViewController *password = [controller.storyboard instantiateViewControllerWithIdentifier:@"CreatePasscodeViewController"];
        password.target = self;
        password.action = @selector(resetPasscode::);
        password.title = @"Enter New Password";
        password.navigationItem.hidesBackButton = YES;
        password.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:password
                                                      action:@selector(doneButtonAction:)];
        [controller.navigationController pushViewController:password animated:YES];
        return YES;
    }
    return NO;
}

#pragma mark - security scenario four

/*
 
 Methods used when changing the security questions at the request of the user.
 
 */

- (BOOL)verifyPasscodeOnQuestionsChange :(IMSPasswordViewController *)controller :(NSString *)passcode {
    if (HRCryptoManagerUnlockWithPasscode(passcode)) {
        HRSecurityQuestionsViewController *questions = [controller.storyboard instantiateViewControllerWithIdentifier:@"SecurityQuestionsController"];
        questions.navigationItem.hidesBackButton = YES;
        questions.mode = HRSecurityQuestionsViewControllerModeCreate;
        questions.delegate = self;
        questions.title = @"Security Questions";
        questions.action = @selector(updateSecurityQuestions:::);
        [controller.navigationController pushViewController:questions animated:YES];
        return YES;
    }
    return NO;
}

- (void)updateSecurityQuestions :(HRSecurityQuestionsViewController *)controller :(NSArray *)questions :(NSArray *)answers {
    HRCryptoManagerUpdateSecurityQuestionsAndAnswers(questions, answers);
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - security scenario five

- (void)initialLoginDidSucceed :(HRRHExLoginViewController *)login {
    HRPeopleSetupViewController *setup = [login.storyboard instantiateViewControllerWithIdentifier:@"PeopleSetupViewController"];
    setup.navigationItem.hidesBackButton = YES;
    [login.navigationController pushViewController:setup animated:YES];
}

#pragma mark - security questions delegate

- (NSUInteger)numberOfSecurityQuestions {
    return 2;
}

- (NSArray *)securityQuestions {
    return HRCryptoManagerSecurityQuestions();
}

@end
