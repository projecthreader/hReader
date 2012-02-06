//
//  HRAppDelegate.m
//  HReader
//
//  Created by Marshall Huss on 11/14/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "HRAppDelegate.h"
#import "HRPasscodeWarningViewController.h"
#import "HRPrivacyViewController.h"

#import "PINCodeViewController.h"

@interface HRAppDelegate ()
- (void)presentPINCodeViewController:(BOOL)animated;
@end

@implementation HRAppDelegate

@synthesize window                  = __window;
@synthesize privacyViewController   = __privacyViewController;

#pragma mark - object methods
- (void)dealloc {
    [__window release];
    [__privacyViewController release];
    [super dealloc];
}
- (void)presentPINCodeViewController:(BOOL)animated {
#if !defined(DEBUG)// || 1
    static BOOL visible = NO;
    if (!visible) {
        visible = YES;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PINCodeStoryboard" bundle:nil];
        UINavigationController *navigation = [storyboard instantiateInitialViewController];
        PINCodeViewController *PIN = [navigation.viewControllers objectAtIndex:0];
        PIN.mode = PINCodeViewControllerModeVerify;
        PIN.title = @"Enter Passcode";
        PIN.messageText = @"Enter passcode (it's 123456)";
        PIN.errorText = @"Incorrect passcode";
        PIN.verifyBlock = ^(NSString *code) {
            BOOL correct = [code isEqualToString:@"123456"];
            visible = !correct;
            return correct;
        };
        UIViewController *controller = self.window.rootViewController;
        if (controller.presentedViewController) {
            [controller dismissModalViewControllerAnimated:NO];
        }
        [controller presentModalViewController:navigation animated:animated];
    }
#endif
}

#pragma mark - application lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // test flight
#if !defined(DEBUG)// || 1
    [TestFlight takeOff:[HRConfig testFlightTeamToken]];
#endif
    
    // appearance proxies
//    UIView *grayView = [[[UIView alloc] init] autorelease];
//    grayView.backgroundColor = [UIColor lightGrayColor];
//    [[UITableViewCell appearance] setSelectedBackgroundView:grayView];
    
    // show window so we can present stuff
    [self.window makeKeyAndVisible];
    
    // show pin code
    [self presentPINCodeViewController:NO];
    
#if !defined(DEBUG) || 1
    //    [self showPrivacyWarning];
#endif
    
    //    [self setupPrivacyView];
    
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
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    //    [TestFlight passCheckpoint:@"Window Hidden"];
    //    self.window.hidden = YES;
    [self presentPINCodeViewController:NO];
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

- (void)showPrivacyWarning {
    if (![HRConfig hasLaunched]) {
        HRPasscodeWarningViewController *warningViewController = [[HRPasscodeWarningViewController alloc] initWithNibName:nil bundle:nil];
        [self.window.rootViewController presentModalViewController:warningViewController animated:NO];
        [warningViewController release];
    }
}


- (void)setupPrivacyView {
    self.privacyViewController = [[[HRPrivacyViewController alloc] initWithNibName:nil bundle:nil] autorelease];
}

@end
