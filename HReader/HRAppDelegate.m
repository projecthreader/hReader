//
//  HRAppDelegate.m
//  HReader
//
//  Created by Marshall Huss on 11/14/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <objc/message.h>

#import "HRAppDelegate.h"
#import "HRPasscodeWarningViewController.h"
#import "HRPrivacyViewController.h"
#import "HRKeychainManager.h"
#import "HRAppletConfigurationViewController.h"
#import "HRSparkLineView.h"

#import "TestFlight.h"

#import "HRMPatient.h"

#import "SVPanelViewController.h"

#import "HROAuthController.h"

#import "DDXML.h"

@interface HRAppDelegate () {
@private
    NSUInteger passcodeAttempts;
}

- (void)presentPasscodeVerifyController;

@end

@implementation HRAppDelegate

@synthesize window = _window;

#pragma mark - class methods

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    static NSPersistentStoreCoordinator *coordinator = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
        coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 NSFileProtectionComplete, NSPersistentStoreFileProtectionKey,
                                 nil];
        NSError *error = nil;
        NSPersistentStore *store = [coordinator
                                    addPersistentStoreWithType:NSInMemoryStoreType
                                    configuration:nil
                                    URL:nil
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

- (void)presentPasscodeVerifyController {
#if !DEBUG// || 1
    passcodeAttempts = 0;
    if ([HRKeychainManager isPasscodeSet]) {
        
        // create view
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PINCodeStoryboard" bundle:nil];
        PINCodeViewController *PIN = [storyboard instantiateViewControllerWithIdentifier:@"PINCodeViewController"];
        PIN.mode = PINCodeViewControllerModeVerify;
        PIN.title = @"Enter Passcode";
        PIN.messageText = @"Enter your passcode";
        PIN.errorText = @"Incorrect passcode";
        PIN.delegate = self;
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:PIN];
        navigation.navigationBar.barStyle = UIBarStyleBlack;
        
        // show view
        UIViewController *rootController = self.window.rootViewController;
        if (rootController.presentedViewController) {
            [rootController dismissModalViewControllerAnimated:NO];
        }
        [rootController presentModalViewController:navigation animated:NO];
        
    }
#endif
}

- (void)dismissModalViewController {
    [self.window.rootViewController.presentedViewController dismissModalViewControllerAnimated:YES];
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
    
    // test flight
#if !TARGET_IPHONE_SIMULATOR
    [TestFlight takeOff:[HRConfig testFlightTeamToken]];
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
    
    // web inspection
#if DEBUG
    @try {
        objc_msgSend(NSClassFromString(@"WebView"), NSSelectorFromString(@"_enableRemoteInspector"));
    }
    @catch (NSException *exception) {
        NSLog(@"Could not turn on remote web inspector\n%@", exception);
    }
#endif
    
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
    
    // configure the user interface
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    SVPanelViewController *panel = (id)self.window.rootViewController;
    panel.mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"RootViewController"];
    panel.rightAccessoryViewController = [storyboard instantiateViewControllerWithIdentifier:@"AppletsConfigurationViewController"];
    panel.leftAccessoryViewController = [storyboard instantiateViewControllerWithIdentifier:@"PeoplePickerViewController"];
    [self.window makeKeyAndVisible];
    
# if !DEBUG
    if ([HRKeychainManager isPasscodeSet]) {
        [self presentPasscodeVerifyController];
    }
    else {
        
        // create view
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PINCodeStoryboard" bundle:nil];
        PINCodeViewController *PIN = [storyboard instantiateViewControllerWithIdentifier:@"PINCodeViewController"];
        PIN.mode = PINCodeViewControllerModeCreate;
        PIN.title = @"Set Passcode";
        PIN.messageText = @"Enter a passcode";
        PIN.confirmText = @"Verify passcode";
        PIN.errorText = @"The passcodes do not match";
        PIN.delegate = self;
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:PIN];
        navigation.navigationBar.barStyle = UIBarStyleBlack;
        
        // show view
        [self.window.rootViewController presentModalViewController:navigation animated:NO];
        
        // show alert
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Welcome"
                              message:@"Before you start using hReader, you must set a passcode and create security questions."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        
    }
#endif
    
    double delay = 5.0;
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        
        // make a scratch context
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
        [context setPersistentStoreCoordinator:[HRAppDelegate persistentStoreCoordinator]];
        NSMutableURLRequest * __block request = nil;
        
        // get list of patient ids
        request = [HROAuthController GETRequestWithPath:@"/"];
        NSArray *patientIDs = nil;
        if (request) {
            
            // run request
            NSError *error = nil;
            NSHTTPURLResponse *response = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            // get ids
            DDXMLDocument *document = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
            [[document rootElement] addNamespace:[DDXMLNode namespaceWithName:@"atom" stringValue:@"http://www.w3.org/2005/Atom"]];
            patientIDs = [[document nodesForXPath:@"/atom:feed/atom:entry/atom:id" error:nil] valueForKey:@"stringValue"];
            
        }
        
        // sync each patient
        [patientIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            // get request
            NSString *path = [NSString stringWithFormat:@"/records/%@/c32/%@", obj, obj];
            request = [HROAuthController GETRequestWithPath:path];
            if (request) {
                
                // configure request
                [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                
                // run request
                NSError *error = nil;
                NSHTTPURLResponse *response = nil;
                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                
                // create patient
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                [HRMPatient instanceWithDictionary:dictionary inContext:context];
                
            }
            
        }];
        
        
//        [HROAuthController GETRequestWithPath:@"/records/5/c32/5" completion:^(NSMutableURLRequest *request) {
//            if (request) {
//                [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//                NSLog(@"%@", [request URL]);
//                NSLog(@"%@", [request allHTTPHeaderFields]);
//                NSHTTPURLResponse *response = nil;
//                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
//                NSLog(@"%d", [response statusCode]);
//                NSLog(@"%@", [[response allHeaderFields] objectForKey:@"Content-Type"]);
//                NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//            }
//        }];
        
        // save
        [context save:nil];
        
    });
    
    // return
    return YES;
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    //    [TestFlight passCheckpoint:@"Window Hidden"];
    //    self.window.hidden = YES;
    //    [self.window.rootViewController dismissModalViewControllerAnimated:NO];
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self presentPasscodeVerifyController];
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
    //    [TestFlight passCheckpoint:@"Window Unhidden"];
    //    self.window.hidden = NO;
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    //    [self.privacyViewController.view removeFromSuperview];
    //    [TestFlight passCheckpoint:@"Window Unhidden"];
    //    self.window.hidden = NO;
    //    [TestFlight passCheckpoint:@"PIN Code Presented"];
    //    GCPINViewController *PIN = [self pinCodeViewController];
    //    [PIN presentFromViewController:self.window.rootViewController animated:NO];
}
- (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application {
    [HRConfig setPasscodeEnabled:YES];
}
- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application {
    
}


#pragma mark - Privacy warning

//- (void)showPrivacyWarning {
//    if (![HRConfig hasLaunched]) {
//        HRPasscodeWarningViewController *warningViewController = [[HRPasscodeWarningViewController alloc] initWithNibName:nil bundle:nil];
//        [self.window.rootViewController presentModalViewController:warningViewController animated:NO];
//        [warningViewController release];
//    }
//}
//
//
//- (void)setupPrivacyView {
//    self.privacyViewController = [[[HRPrivacyViewController alloc] initWithNibName:nil bundle:nil] autorelease];
//}

#pragma mark - pin code

- (NSUInteger)PINCodeLength {
    return 6;
}

- (void)PINCodeViewController:(PINCodeViewController *)controller didCreatePIN:(NSString *)PIN {
    [HRKeychainManager setPasscode:PIN];
    if ([controller.userInfo isEqualToString:@"change_passcode"] || [controller.userInfo isEqualToString:@"reset_passcode"]) {
        [controller dismissModalViewControllerAnimated:YES];
    }
    else {
        
        // security questions
        PINSecurityQuestionsViewController *questions = [controller.storyboard instantiateViewControllerWithIdentifier:@"SecurityQuestionsController"];
        questions.navigationItem.hidesBackButton = YES;
        questions.mode = PINSecurityQuestionsViewControllerCreate;
        questions.delegate = self;
        questions.title = @"Security Questions";
        
        // show
        [controller.navigationController pushViewController:questions animated:YES];
        
    }
}

- (BOOL)PINCodeViewController:(PINCodeViewController *)controller isValidPIN:(NSString *)PIN {
    BOOL valid = [HRKeychainManager isPasscodeValid:PIN];
    if (valid) {
        if ([controller.userInfo isEqualToString:@"change_passcode"]) {
            PINCodeViewController *create = [controller.storyboard instantiateViewControllerWithIdentifier:@"PINCodeViewController"];
            create.mode = PINCodeViewControllerModeCreate;
            create.title = @"Set Passcode";
            create.messageText = @"Enter a passcode";
            create.confirmText = @"Verify passcode";
            create.errorText = @"The passcodes do not match";
            create.userInfo = controller.userInfo;
            create.delegate = (HRAppDelegate *)[[UIApplication sharedApplication] delegate];
            create.navigationItem.leftBarButtonItem = controller.navigationItem.leftBarButtonItem;
            [controller.navigationController pushViewController:create animated:YES];
        }
        else if ([controller.userInfo isEqualToString:@"change_questions"]) {
            PINSecurityQuestionsViewController *questions = [controller.storyboard instantiateViewControllerWithIdentifier:@"SecurityQuestionsController"];
            questions.navigationItem.hidesBackButton = YES;
            questions.mode = PINSecurityQuestionsViewControllerEdit;
            questions.delegate = (HRAppDelegate *)[[UIApplication sharedApplication] delegate];
            questions.title = @"Security Questions";
            questions.navigationItem.leftBarButtonItem = controller.navigationItem.leftBarButtonItem;
            [controller.navigationController pushViewController:questions animated:YES];
        }
        else {
            [controller dismissModalViewControllerAnimated:YES];
        }
    }
    else if (controller.userInfo == nil) {
        if (++passcodeAttempts > 2) {
            UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] 
                                            initWithTitle:@"Reset Passcode" 
                                            style:UIBarButtonItemStyleBordered 
                                            target:self 
                                            action:@selector(resetPasscode:)];
            controller.navigationItem.leftBarButtonItem = resetButton;
        }
    }
    return valid;
}

#pragma mark - security questions delegate

- (NSUInteger)numberOfSecurityQuestions {
    return 2;
}

- (void)securityQuestionsController:(PINSecurityQuestionsViewController *)controller didSubmitQuestions:(NSArray *)questions answers:(NSArray *)answers {
    if (controller.mode == PINSecurityQuestionsViewControllerVerify) {
        if ([HRKeychainManager areAnswersForSecurityQuestionsValid:answers]) {
            PINCodeViewController *create = [controller.storyboard instantiateViewControllerWithIdentifier:@"PINCodeViewController"];
            create.mode = PINCodeViewControllerModeCreate;
            create.title = @"Set Passcode";
            create.messageText = @"Enter a passcode";
            create.confirmText = @"Verify passcode";
            create.errorText = @"The passcodes do not match";
            create.userInfo = @"reset_passcode";
            create.delegate = self;
            create.navigationItem.hidesBackButton = YES;
            [controller.navigationController pushViewController:create animated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] 
                                  initWithTitle:@"Invalid Answers" 
                                  message:@"The answers you provided are not correct" 
                                  delegate:nil 
                                  cancelButtonTitle:@"OK" 
                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    else if (controller.mode == PINSecurityQuestionsViewControllerCreate || controller.mode == PINSecurityQuestionsViewControllerEdit) {
        [HRKeychainManager setSecurityQuestions:questions answers:answers];
        [controller dismissModalViewControllerAnimated:YES];
    }
}

- (NSArray *)securityQuestions {
    return [HRKeychainManager securityQuestions];
}

- (void)resetPasscode:(id)sender {
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController.presentedViewController;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PINCodeStoryboard" bundle:nil];
    PINSecurityQuestionsViewController *questions = [storyboard instantiateViewControllerWithIdentifier:@"SecurityQuestionsController"];
    questions.navigationItem.hidesBackButton = NO;
    questions.mode = PINSecurityQuestionsViewControllerVerify;
    questions.delegate = (HRAppDelegate *)[[UIApplication sharedApplication] delegate];
    questions.title = @"Security Questions";
    [navController pushViewController:questions animated:YES];
}

@end
