//
//  HRAboutTableViewController.m
//  HReader
//
//  Created by Marshall Huss on 12/12/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "HRAboutTableViewController.h"
#import "HRPasscodeWarningViewController.h"
#import "HRKeychainManager.h"
#import "HRAppDelegate.h"

@implementation HRAboutTableViewController

@synthesize versionLabel = __versionLabel;

#pragma mark - button actions

- (IBAction)done {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.versionLabel.text = [HRConfig formattedVersion];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.versionLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // feedback
    if ([cell.reuseIdentifier isEqualToString:@"FeedbackCell"]) {
        [TestFlight openFeedbackView];
    }
    
    // privacy demo
    else if ([cell.reuseIdentifier isEqualToString:@"PrivacyDemoCell"]) {
//        HRPasscodeWarningViewController *warningViewController = [[HRPasscodeWarningViewController alloc] initWithNibName:nil bundle:nil];
//        warningViewController.demoMode = YES;
//        [self presentModalViewController:warningViewController animated:YES];
//        [warningViewController release];
    }
    
    // passcode cell
    else if ([cell.reuseIdentifier isEqualToString:@"ChangePasscodeCell"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PINCodeStoryboard" bundle:nil];
        PINCodeViewController *PIN = [storyboard instantiateViewControllerWithIdentifier:@"PINCodeViewController"];
        PIN.mode = PINCodeViewControllerModeVerify;
        PIN.title = @"Enter Passcode";
        PIN.messageText = @"Enter your passcode";
        PIN.errorText = @"Incorrect passcode";
        PIN.delegate = (HRAppDelegate *)[[UIApplication sharedApplication] delegate];
        PIN.userInfo = @"change_passcode";
        PIN.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                target:[[UIApplication sharedApplication] delegate]
                                                action:@selector(dismissModalViewController)];
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:PIN];
        navigation.navigationBar.barStyle = UIBarStyleBlack;
        navigation.definesPresentationContext = YES;
        [self presentModalViewController:navigation animated:YES];
    }
    
    // questions cell
    else if ([cell.reuseIdentifier isEqualToString:@"ChangeQuestionsCell"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PINCodeStoryboard" bundle:nil];
        PINCodeViewController *PIN = [storyboard instantiateViewControllerWithIdentifier:@"PINCodeViewController"];
        PIN.mode = PINCodeViewControllerModeVerify;
        PIN.title = @"Enter Passcode";
        PIN.messageText = @"Enter your passcode";
        PIN.errorText = @"Incorrect passcode";
        PIN.delegate = (HRAppDelegate *)[[UIApplication sharedApplication] delegate];
        PIN.userInfo = @"change_questions";
        PIN.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                target:[[UIApplication sharedApplication] delegate]
                                                action:@selector(dismissModalViewController)];
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:PIN];
        navigation.navigationBar.barStyle = UIBarStyleBlack;
        navigation.definesPresentationContext = YES;
        
        // show
        UIViewController *controller = self.presentingViewController;
        [self dismissViewControllerAnimated:YES completion:^{
            [controller presentModalViewController:navigation animated:YES];
        }];
        
    }

}

@end
