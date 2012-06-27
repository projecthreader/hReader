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

#import "HRAppDelegate.h"
#import "HRAPIClient.h"
#import "HRRHExLoginViewController.h"
#import "HRPeopleSetupViewController.h"
#import "HRCryptoManager.h"
#import "HRSplashScreenViewController.h"
#import "HRPasscodeViewController.h"

#import "HRKeychainManager.h"
#import "HRAppletConfigurationViewController.h"

#import "TestFlight.h"

#import "HRMPatient.h"

#import "SVPanelViewController.h"

#import "HRCryptoManager.h"

#import "SSKeychain.h"

@interface HRAppDelegate () {
    NSUInteger passcodeAttempts;
    UINavigationController *securityNavigationController;
}

@end

@implementation HRAppDelegate

@synthesize window = _window;

#pragma mark - class methods

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    static NSPersistentStoreCoordinator *coordinator = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        
        // get the model
        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        // get the coordinator
        coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        // add store
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *applicationSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
        [fileManager createDirectoryAtURL:applicationSupportURL withIntermediateDirectories:NO attributes:nil error:nil];
        NSURL *databaseURL = [applicationSupportURL URLByAppendingPathComponent:@"database.sqlite"];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 NSFileProtectionComplete, NSPersistentStoreFileProtectionKey,
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                                 nil];
        NSError *error = nil;
        NSPersistentStore *store = [coordinator
                                    addPersistentStoreWithType:NSSQLiteStoreType
                                    configuration:nil
                                    URL:databaseURL
                                    options:options
                                    error:&error];
        NSAssert(store, @"Unable to add persistent store\n%@", error);
        
    });
    return coordinator;
}

+ (NSManagedObjectContext *)managedObjectContext {
    static NSManagedObjectContext *context = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [context setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    });
    return context;
}

#pragma mark - object methods

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

- (void)performLaunchSteps {
    
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
#define PEACE_OUT() raise(SIGKILL); abort(); exit(EXIT_FAILURE);
#define LOL_STR(_key, _input) for (size_t _i = 0; _i < strlen(_input); _i++) { _input[_i] ^= _key; }
    
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
    LOL_STR(243, path1);
#if DEBUG
    NSLog(@"Checking for %s", path1);
#endif
    struct stat s1;
    if (stat(path1, &s1) == 0) { // file exists
        PEACE_OUT();
    };
    
    // sshd test
    char path2[] = {
        230, 188, 186, 187, 230, 171, 160, 167, 230, 186, 186, 161, 173, '\0'
    };
    LOL_STR(201, path2);
#if DEBUG
    NSLog(@"Checking for %s", path2);
#endif
    struct stat s2;
    if (stat(path2, &s2) == 0) { // file exists
        PEACE_OUT();
    };
    
#endif
    
    // check for passcode
    if (!HRCryptoManagerHasPasscode() || !HRCryptoManagerHasSecurityQuestions()) {
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
        
        // check for accounts
        if ([hosts count] == 0) {
            id controller = [HRRHExLoginViewController loginViewControllerWithHost:@"growing-spring-4857.herokuapp.com"];
            [[controller navigationItem] setHidesBackButton:YES];
            [(id)self.window.rootViewController pushViewController:controller animated:YES];
        }
        
        // check user interface
        else if ([[(id)self.window.rootViewController topViewController] isKindOfClass:[HRSplashScreenViewController class]]) {
            NSString *host = [hosts lastObject];
            [[HRAPIClient clientWithHost:host] patientFeed:nil];
            [HRMPatient performSync];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"InitialSetup_iPad" bundle:nil];
            id controller = [storyboard instantiateViewControllerWithIdentifier:@"PeopleSetupViewController"];
            [[controller navigationItem] setHidesBackButton:YES];
            [(id)self.window.rootViewController pushViewController:controller animated:YES];
        }
        
    }
    
    // locked
    else {
        [self presentPasscodeVerificationController:YES];
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

#pragma mark - notifications

- (void)managedObjectContextDidSave:(NSNotification *)notification {
    NSManagedObjectContext *context = [HRAppDelegate managedObjectContext];
    if ([notification object] != context) {
        [context mergeChangesFromContextDidSaveNotification:notification];
    }
}

#pragma mark - application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // debugging
#if TARGET_IPHONE_SIMULATOR
    @try {
        objc_msgSend(NSClassFromString(@"WebView"), NSSelectorFromString(@"_enableRemoteInspector"));
    }
    @catch (NSException *exception) {
        NSLog(@"Could not turn on remote web inspector\n%@", exception);
    }
#elif !DEBUG
    [TestFlight takeOff:@"e8ef4e7b3c88827400af56886c6fe280_MjYyNTYyMDExLTEwLTE5IDE2OjU3OjQ3LjMyNDk4OQ"];
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
    
    // keychain
    [SSKeychain setAccessibilityType:kSecAttrAccessibleWhenUnlockedThisDeviceOnly];
    
    // notifications
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(managedObjectContextDidSave:)
     name:NSManagedObjectContextDidSaveNotification
     object:nil];
    
    // load patients if we don't have any yet
//    NSManagedObjectContext *context = [HRAppDelegate managedObjectContext];
//    if ([HRMPatient countInContext:context] == 0) {
//        NSArray *names = [NSArray arrayWithObjects:@"hs", @"js", @"ms", @"ss", @"ts", @"ns", nil];
//        [names enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
//            
//            // load real data
//            NSURL *URL = [[NSBundle mainBundle] URLForResource:name withExtension:@"json"];
//            NSData *data = [NSData dataWithContentsOfURL:URL];
//            NSError *JSONError = nil;
//            HRMPatient *patient = nil;
//            id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
//            if (object) { patient = [HRMPatient instanceWithDictionary:object inContext:context]; }
//            else { NSLog(@"%@: %@", name, JSONError); }
//            
//            // load synthetic data
//            NSURL *syntheticURL = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"%@-synthetic", name] withExtension:@"json"];
//            NSData *syntheticData = [NSData dataWithContentsOfURL:syntheticURL];
//            if (syntheticData) {
//                NSError *error = nil;
//                patient.syntheticInfo = [NSJSONSerialization JSONObjectWithData:syntheticData options:0 error:&error];
//                patient.applets = [patient.syntheticInfo objectForKey:@"applets"];
//                if (error) {
//                    NSLog(@"Unable to load synthetic patient file %@\n%@", name, error);
//                }
//            }
//            
//        }];
//        NSError *error = nil;
//        BOOL save = [context save:&error];
//        NSAssert(save, @"Unable to import patients\n%@", error);
//    }
    
    double delay = 1.0;
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [self performLaunchSteps];
    });
    
    // return
    return YES;
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    HRCryptoManagerPurge();
    if (!HRCryptoManagerHasPasscode() || !HRCryptoManagerHasSecurityQuestions()) {
        [(id)self.window.rootViewController popToRootViewControllerAnimated:NO];
    }
    [securityNavigationController dismissModalViewControllerAnimated:NO];
    securityNavigationController = nil;
    [self presentPasscodeVerificationController:NO];
}

#pragma mark - passcode

- (NSUInteger)PINCodeLength {
    return 6;
}

- (void)createInitialPasscode:(HRPasscodeViewController *)controller :(NSString *)passcode {
    HRCryptoManagerStoreTemporaryPasscode(passcode);
    HRSecurityQuestionsViewController *questions = [controller.storyboard instantiateViewControllerWithIdentifier:@"SecurityQuestionsController"];
    questions.navigationItem.hidesBackButton = YES;
    questions.mode = HRSecurityQuestionsViewControllerModeCreate;
    questions.delegate = self;
    questions.title = @"Security Questions";
    questions.action = @selector(createInitialSecurityQuestions:::);
    [controller.navigationController pushViewController:questions animated:YES];
}

- (void)resetPasscode:(HRPasscodeViewController *)controller :(NSString *)passcode {
    HRCryptoManagerUpdatePasscode(passcode);
    [controller dismissViewControllerAnimated:YES completion:^{
        [self performLaunchSteps];
    }];
}

- (BOOL)verifyPasscodeOnLaunch:(HRPasscodeViewController *)controller :(NSString *)passcode {
    if (HRCryptoManagerUnlockWithPasscode(passcode)) {
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

- (BOOL)verifyPasscodeOnChange:(HRPasscodeViewController *)controller :(NSString *)passcode {
    if (HRCryptoManagerUnlockWithPasscode(passcode)) {
        HRPasscodeViewController *passcode = [controller.storyboard instantiateViewControllerWithIdentifier:@"CreatePasscodeViewController"];
        passcode.mode = HRPasscodeViewControllerModeCreate;
        passcode.target = self;
        passcode.action = @selector(resetPasscode::);
        passcode.title = @"Enter New Passcode";
        passcode.navigationItem.hidesBackButton = YES;
        [controller.navigationController pushViewController:passcode animated:YES];
//        [controller dismissViewControllerAnimated:YES completion:^{
//            [controller presentModalViewController:securityNavigationController animated:YES];
//        }];
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




//- (void)PINCodeViewController:(PINCodeViewController *)controller didCreatePIN:(NSString *)PIN {
////    [HRKeychainManager setPasscode:PIN];
//    if ([controller.userInfo isEqualToString:@"change_passcode"] || [controller.userInfo isEqualToString:@"reset_passcode"]) {
//        [controller dismissModalViewControllerAnimated:YES];
//    }
//    else {
//        HRCryptoManagerStoreTemporaryPasscode(PIN);
//        PINSecurityQuestionsViewController *questions = [controller.storyboard instantiateViewControllerWithIdentifier:@"SecurityQuestionsController"];
//        questions.navigationItem.hidesBackButton = YES;
//        questions.mode = PINSecurityQuestionsViewControllerCreate;
//        questions.delegate = self;
//        questions.title = @"Security Questions";
//        [controller.navigationController pushViewController:questions animated:YES];
//    }
//}

//- (BOOL)PINCodeViewController:(PINCodeViewController *)controller isValidPIN:(NSString *)PIN {
//    BOOL valid = [HRKeychainManager isPasscodeValid:PIN];
//    if (valid) {
//        if ([controller.userInfo isEqualToString:@"change_passcode"]) {
//            PINCodeViewController *create = [controller.storyboard instantiateViewControllerWithIdentifier:@"PINCodeViewController"];
//            create.mode = PINCodeViewControllerModeCreate;
//            create.title = @"Set Passcode";
//            create.messageText = @"Enter a passcode";
//            create.confirmText = @"Verify passcode";
//            create.errorText = @"The passcodes do not match";
//            create.userInfo = controller.userInfo;
//            create.delegate = (HRAppDelegate *)[[UIApplication sharedApplication] delegate];
//            create.navigationItem.leftBarButtonItem = controller.navigationItem.leftBarButtonItem;
//            [controller.navigationController pushViewController:create animated:YES];
//        }
//        else if ([controller.userInfo isEqualToString:@"change_questions"]) {
//            PINSecurityQuestionsViewController *questions = [controller.storyboard instantiateViewControllerWithIdentifier:@"SecurityQuestionsController"];
//            questions.navigationItem.hidesBackButton = YES;
//            questions.mode = PINSecurityQuestionsViewControllerEdit;
//            questions.delegate = (HRAppDelegate *)[[UIApplication sharedApplication] delegate];
//            questions.title = @"Security Questions";
//            questions.navigationItem.leftBarButtonItem = controller.navigationItem.leftBarButtonItem;
//            [controller.navigationController pushViewController:questions animated:YES];
//        }
//        else {
//            [controller dismissModalViewControllerAnimated:YES];
//        }
//    }
//    else if (controller.userInfo == nil) {
//        if (++passcodeAttempts > 2) {
//            UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] 
//                                            initWithTitle:@"Reset Passcode" 
//                                            style:UIBarButtonItemStyleBordered 
//                                            target:self 
//                                            action:@selector(resetPasscode:)];
//            controller.navigationItem.leftBarButtonItem = resetButton;
//        }
//    }
//    return valid;
//}

#pragma mark - security questions delegate

- (NSUInteger)numberOfSecurityQuestions {
    return 2;
}

- (NSArray *)securityQuestions {
    return HRCryptoManagerSecurityQuestions();
}

- (void)createInitialSecurityQuestions:(HRSecurityQuestionsViewController *)controller :(NSArray *)questions :(NSArray *)answers {
    HRCryptoManagerStoreTemporarySecurityQuestionsAndAnswers(questions, answers);
    HRCryptoManagerFinalize();
    [self performLaunchSteps];
}

- (void)resetPasscodeWithSecurityQuestions:(HRSecurityQuestionsViewController *)controller :(NSArray *)questions :(NSArray *)answers {
    if (HRCryptoManagerUnlockWithAnswersForSecurityQuestions(answers)) {
        HRPasscodeViewController *passcode = [controller.storyboard instantiateViewControllerWithIdentifier:@"CreatePasscodeViewController"];
        passcode.mode = HRPasscodeViewControllerModeCreate;
        passcode.target = self;
        passcode.action = @selector(resetPasscode::);
        passcode.title = @"Enter Passcode";
        passcode.navigationItem.hidesBackButton = YES;
        [controller.navigationController pushViewController:passcode animated:YES];

//        HRPasscodeViewController *passcode = [controller.storyboard instantiateViewControllerWithIdentifier:@"CreatePasscodeViewController"];
//        passcode.mode = HRPasscodeViewControllerModeVerify;
        
//        PINCodeViewController *PIN = [controller.storyboard instantiateViewControllerWithIdentifier:@"PINCodeViewController"];
//        PIN.mode = PINCodeViewControllerModeCreate;
//        PIN.title = @"Set Passcode";
//        PIN.messageText = @"Enter a passcode";
//        PIN.confirmText = @"Verify passcode";
//        PIN.errorText = @"The passcodes do not match";
//        PIN.delegate = self;
//        PIN.action = @selector(createInitialPasscode::);
//        PIN.navigationItem.hidesBackButton = YES;
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

//- (void)securityQuestionsController:(PINSecurityQuestionsViewController *)controller didSubmitQuestions:(NSArray *)questions answers:(NSArray *)answers {
//    if (controller.mode == PINSecurityQuestionsViewControllerVerify) {
//        if ([HRKeychainManager areAnswersForSecurityQuestionsValid:answers]) {
//            PINCodeViewController *create = [controller.storyboard instantiateViewControllerWithIdentifier:@"PINCodeViewController"];
//            create.mode = PINCodeViewControllerModeCreate;
//            create.title = @"Set Passcode";
//            create.messageText = @"Enter a passcode";
//            create.confirmText = @"Verify passcode";
//            create.errorText = @"The passcodes do not match";
//            create.userInfo = @"reset_passcode";
//            create.delegate = self;
//            create.navigationItem.hidesBackButton = YES;
//            [controller.navigationController pushViewController:create animated:YES];
//        } else {
//            UIAlertView *alert = [[UIAlertView alloc] 
//                                  initWithTitle:@"Invalid Answers" 
//                                  message:@"The answers you provided are not correct" 
//                                  delegate:nil 
//                                  cancelButtonTitle:@"OK" 
//                                  otherButtonTitles:nil];
//            [alert show];
//        }
//    }
//    else if (controller.mode == PINSecurityQuestionsViewControllerCreate || controller.mode == PINSecurityQuestionsViewControllerEdit) {
////        [HRKeychainManager setSecurityQuestions:questions answers:answers];
//        HRCryptoManagerStoreTemporarySecurityQuestionsAndAnswers(questions, answers);
//        HRCryptoManagerFinalize();
////        [controller dismissModalViewControllerAnimated:YES];
//    }
//}

//- (void)resetPasscode:(id)sender {
//    UINavigationController *navController = (UINavigationController *)self.window.rootViewController.presentedViewController;
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PINCodeStoryboard" bundle:nil];
//    PINSecurityQuestionsViewController *questions = [storyboard instantiateViewControllerWithIdentifier:@"SecurityQuestionsController"];
//    questions.navigationItem.hidesBackButton = NO;
//    questions.mode = PINSecurityQuestionsViewControllerVerify;
//    questions.delegate = (HRAppDelegate *)[[UIApplication sharedApplication] delegate];
//    questions.title = @"Security Questions";
//    [navController pushViewController:questions animated:YES];
//}

@end
