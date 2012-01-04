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

@implementation HRAppDelegate

@synthesize window = _window;
@synthesize privacyViewController = __privacyViewController;

- (void)dealloc {
    [_window release];
    [__privacyViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self loadTestFlight];
    
    [self.window makeKeyAndVisible];
        
#if !defined(DEBUG)// || 1
    [self showPrivacyWarning];
#endif
    
    [self setupPrivacyView];

    [self setAppearanceProxies];
    
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
//        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
//        splitViewController.delegate = (id)navigationController.topViewController;
//    }
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
//    [self.window addSubview:self.privacyViewController.view];
    self.window.hidden = YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
//    [self.privacyViewController.view removeFromSuperview];
    self.window.hidden = NO;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application {
    [HRConfig setPasscodeEnabled:YES];
}

- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application {
}

- (void)setAppearanceProxies {
//    UIView *redView = [[UIView alloc] init];
//    redView.backgroundColor = [UIColor hReaderLightRed];
//    [[UITableViewCell appearance] setSelectedBackgroundView:redView];
//    [redView release];
}

#pragma mark - Privacy warning

- (void)showPrivacyWarning {
    if (![HRConfig hasLaunched]) {
        HRPasscodeWarningViewController *warningViewController = [[HRPasscodeWarningViewController alloc] initWithNibName:nil bundle:nil];
        [self.window.rootViewController presentModalViewController:warningViewController animated:NO];
        [warningViewController release];
    }
}

// Load TestFlight SDK
- (void)loadTestFlight {
#if !defined(DEBUG)// || 1
    [TestFlight takeOff:[HRConfig testFlightTeamToken]];
#endif 
}

- (void)setupPrivacyView {
    self.privacyViewController = [[HRPrivacyViewController alloc] initWithNibName:nil bundle:nil];
}


@end
