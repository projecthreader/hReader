//
//  HRAppDelegate.m
//  HReader
//
//  Created by Marshall Huss on 11/14/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "HRAppDelegate.h"
#import "HRPasscodeWarningViewController.h"
#import "HRPrivacyViewController.h"
#import "HRKeychainManager.h"

#import "HRMPatient.h"

@interface HRAppDelegate ()
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (void)presentPasscodeVerifyController;
@end

@implementation HRAppDelegate

@synthesize window = __window;

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
#if !defined(DEBUG) || 1
    if ([HRKeychainManager isPasscodeSet]) {
        
        // create view
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PINCodeStoryboard" bundle:nil];
        PINCodeViewController *PIN = [storyboard instantiateViewControllerWithIdentifier:@"PINCodeViewController"];
        PIN.mode = PINCodeViewControllerModeVerify;
        PIN.title = @"Enter Passcode";
        PIN.messageText = @"Enter your passcode";
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

#pragma mark - application lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // test flight
#if !TARGET_IPHONE_SIMULATOR
    [TestFlight takeOff:[HRConfig testFlightTeamToken]];
#endif
    
    // load patients if we don't have any yet
    NSManagedObjectContext *context = [HRAppDelegate managedObjectContext];
    if ([HRMPatient countInContext:context] == 0) {
        NSArray *names = [NSArray arrayWithObjects:@"hs", @"js", @"ms", @"ss", @"ts", nil];
        [names enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSURL *URL = [[NSBundle mainBundle] URLForResource:obj withExtension:@"json"];
            NSData *data = [NSData dataWithContentsOfURL:URL];
            id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            [HRMPatient instanceWithDictionary:object inContext:context];
        }];
        NSError *error = nil;
        BOOL save = [context save:&error];
        NSAssert(save, @"Unable to import patients\n%@", error);
    }
    NSArray *patients = [HRMPatient patientsInContext:context];
    [HRMPatient setSelectedPatient:[patients objectAtIndex:0]];
    
    // show window so we can present stuff
    [self.window makeKeyAndVisible];
    
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

#pragma mark - security questions delegate

- (NSUInteger)numberOfSecurityQuestions {
    return 2;
}

- (void)securityQuestionsController:(PINSecurityQuestionsViewController *)controller didSubmitQuestions:(NSArray *)questions answers:(NSArray *)answers {
    [HRKeychainManager setSecurityQuestions:questions answers:answers];
    [controller dismissModalViewControllerAnimated:YES];
}

#pragma mark - pin code

- (NSUInteger)PINCodeLength {
    return 6;
}

- (void)PINCodeViewController:(PINCodeViewController *)controller didSubmitPIN:(NSString *)PIN {
    if (controller.mode == PINCodeViewControllerModeVerify) {
        if ([HRKeychainManager isPasscodeValid:PIN]) {
            [controller dismissModalViewControllerAnimated:YES];
        }
        else {
            controller.errorLabel.text = @"Incorrect passcode";
            controller.errorLabel.hidden = NO;
        }
    }
    else {
        
        // save passcode
        [HRKeychainManager setPasscode:PIN];
        
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

@end
