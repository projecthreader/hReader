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
#import "HRPasscodeViewController.h"
#import "HRHIPPAMessageViewController.h"
#import "HRAppletConfigurationViewController.h"
#import "HRCryptoManager.h"
#import "HRMPatient.h"

#import "SSKeychain.h"

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
        NSURL *databaseURL = [applicationSupportURL URLByAppendingPathComponent:@"database.sqlite3"];
        NSDictionary *options = @{
            NSPersistentStoreFileProtectionKey : NSFileProtectionComplete,
            NSMigratePersistentStoresAutomaticallyOption : @YES,
            NSInferMappingModelAutomaticallyOption : @YES
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
#define PEACE_OUT() raise(SIGKILL); abort(); exit(EXIT_FAILURE);
    
    // fork test
    pid_t child = fork();
    if (child == 0) { exit(0); } // child process should exit
    if (child > 0) { // fork succeeded, compromised!
        PEACE_OUT();
    }
    
    // mobile substrate test
    char path1[] = {
        220, 191, 154, 145, 129, 146, 129, 138, 220, 190, 156, 145, 154, 159,
        150, 160, 134, 145, 128, 135, 129, 146, 135, 150, 220, 190, 156, 145,
        154, 159, 150, 160, 134, 145, 128, 135, 129, 146, 135, 150, 221, 151,
        138, 159, 154, 145, '\0'
    };
    XOR(243, path1, strlen(path1));
    HRDebugLog(@"Checking for %s", path1);
    struct stat s1;
    if (stat(path1, &s1) == 0) { // file exists
        PEACE_OUT();
    };
    
    // sshd test
    char path2[] = {
        230, 188, 186, 187, 230, 171, 160, 167, 230, 186, 186, 161, 173, '\0'
    };
    XOR(201, path2, strlen(path2));
    HRDebugLog(@"Checking for %s", path2);
    struct stat s2;
    if (stat(path2, &s2) == 0) { // file exists
        PEACE_OUT();
    };
    
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
        HRPasscodeViewController *passcode = [storyboard instantiateViewControllerWithIdentifier:@"CreatePasscodeViewController"];
        passcode.mode = HRPasscodeViewControllerModeCreate;
        passcode.title = @"Set Passcode";
        passcode.target = self;
        passcode.action = @selector(createInitialPasscode::);
        passcode.navigationItem.hidesBackButton = YES;
        [(id)self.window.rootViewController pushViewController:passcode animated:YES];
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
//            HRAPIClient *client = [HRAPIClient clientWithHost:@"growing-spring-4857.herokuapp.com"];
            HRAPIClient *client = [HRAPIClient clientWithHost:@"hreader-rhex-staging.herokuapp.com"];
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
    
    // keychain
    [SSKeychain setAccessibilityType:kSecAttrAccessibleWhenUnlockedThisDeviceOnly];
    
    // notifications
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(managedObjectContextDidSave:)
     name:NSManagedObjectContextDidSaveNotification
     object:nil];
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [self performLaunchSteps];
    });
    
    // return
    return YES;
    
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

- (void)createInitialPasscode :(HRPasscodeViewController *)controller :(NSString *)passcode {
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
    HRPasscodeViewController *passcode = [storyboard instantiateViewControllerWithIdentifier:@"VerifyPasscodeViewController"];
    passcode.mode = HRPasscodeViewControllerModeVerify;
    passcode.target = self;
    passcode.action = @selector(verifyPasscodeOnLaunch::);
    passcode.title = @"Enter Passcode";
    securityNavigationController = [[UINavigationController alloc] initWithRootViewController:passcode];
    UIViewController *controller = self.window.rootViewController;
    while (YES) {
        UIViewController *presented = controller.presentedViewController;
        if (presented) { controller = presented; }
        else { break; }
    }
    [controller presentViewController:securityNavigationController animated:animated completion:nil];
}

- (BOOL)verifyPasscodeOnLaunch :(HRPasscodeViewController *)controller :(NSString *)passcode {
    if (HRCryptoManagerUnlockWithPasscode(passcode)) {
        [self addPersistentStoreIfNeeded];
        [controller dismissViewControllerAnimated:YES completion:^{
            securityNavigationController = nil;
            [self performLaunchSteps];
        }];
        return YES;
    }
    else {
        [[[UIAlertView alloc]
          initWithTitle:@"The passcode you provided is not correct."
          message:nil
          delegate:nil
          cancelButtonTitle:@"OK"
          otherButtonTitles:nil]
         show];
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
        HRPasscodeViewController *passcode = [controller.storyboard instantiateViewControllerWithIdentifier:@"CreatePasscodeViewController"];
        passcode.mode = HRPasscodeViewControllerModeCreate;
        passcode.target = self;
        passcode.action = @selector(resetPasscode::);
        passcode.title = @"Enter Passcode";
        passcode.navigationItem.hidesBackButton = YES;
        [controller.navigationController pushViewController:passcode animated:YES];
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

- (void)resetPasscode :(HRPasscodeViewController *)controller :(NSString *)passcode {
    HRCryptoManagerUpdatePasscode(passcode);
    [controller dismissViewControllerAnimated:YES completion:^{
        [self performLaunchSteps];
    }];
}

#pragma mark - security scenario three

/*
 
 Methods used when changing the passcode at the request of the user.
 
 */

- (BOOL)verifyPasscodeOnPasscodeChange :(HRPasscodeViewController *)controller :(NSString *)passcode {
    if (HRCryptoManagerUnlockWithPasscode(passcode)) {
        HRPasscodeViewController *passcode = [controller.storyboard instantiateViewControllerWithIdentifier:@"CreatePasscodeViewController"];
        passcode.mode = HRPasscodeViewControllerModeCreate;
        passcode.target = self;
        passcode.action = @selector(resetPasscode::);
        passcode.title = @"Enter New Passcode";
        passcode.navigationItem.hidesBackButton = YES;
        passcode.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:passcode
                                                      action:@selector(create:)];
        [controller.navigationController pushViewController:passcode animated:YES];
        return YES;
    }
    else {
        [[[UIAlertView alloc]
          initWithTitle:@"The passcode you provided is not correct."
          message:nil
          delegate:nil
          cancelButtonTitle:@"OK"
          otherButtonTitles:nil]
         show];
        return NO;
    }
}

#pragma mark - security scenario four

/*
 
 Methods used when changing the security questions at the request of the user.
 
 */

- (BOOL)verifyPasscodeOnQuestionsChange :(HRPasscodeViewController *)controller :(NSString *)passcode {
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
    else {
        [[[UIAlertView alloc]
          initWithTitle:@"The passcode you provided is not correct."
          message:nil
          delegate:nil
          cancelButtonTitle:@"OK"
          otherButtonTitles:nil]
         show];
        return NO;
    }
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
