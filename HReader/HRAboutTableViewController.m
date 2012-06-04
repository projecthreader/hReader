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

#import "GCAlertView.h"

#if !__has_feature(objc_arc)
#error This class requires ARC
#endif

@implementation HRAboutTableViewController

@synthesize versionLabel = __versionLabel;
@synthesize buildDateLabel = _buildDateLabel;

#pragma mark - button actions

- (IBAction)done {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.versionLabel.text = [HRConfig formattedVersion];
    self.buildDateLabel.text = [NSString stringWithFormat:@"%s, %s", __DATE__, __TIME__];
}

- (void)viewDidUnload {
    self.buildDateLabel = nil;
    self.versionLabel = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - table view

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // feedback
    if ([cell.reuseIdentifier isEqualToString:@"FeedbackCell"]) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setToRecipients:[NSArray arrayWithObject:[HRConfig feedbackEmailAddress]]];
            [controller setSubject:@"hReader Feedback"];
            [controller
             setMessageBody:[NSString stringWithFormat:
                             @"\n\nApp Version: %@\n",
                             [HRConfig formattedVersion]]
             isHTML:NO];
            [self presentModalViewController:controller animated:YES];
        }
        else {
            GCAlertView *alert = [[GCAlertView alloc]
                                  initWithTitle:nil
                                  message:[NSString stringWithFormat:
                                           @"No email accounts are configured on this %@. Would you like to add one now?",
                                           [[UIDevice currentDevice] model]]];
            [alert addButtonWithTitle:@"Not now" block:nil];
            [alert addButtonWithTitle:@"Yes" block:^{
                NSURL *URL = [NSURL URLWithString:@"mailto:"];
                [[UIApplication sharedApplication] openURL:URL];
            }];
            [alert setCancelButtonIndex:0];
            [alert show];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PINCodeStoryboard" bundle:nil];
//        PINCodeViewController *PIN = [storyboard instantiateViewControllerWithIdentifier:@"PINCodeViewController"];
//        PIN.mode = PINCodeViewControllerModeVerify;
//        PIN.title = @"Enter Passcode";
//        PIN.messageText = @"Enter your passcode";
//        PIN.errorText = @"Incorrect passcode";
//        PIN.delegate = (HRAppDelegate *)[[UIApplication sharedApplication] delegate];
//        PIN.userInfo = @"change_passcode";
//        PIN.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
//                                                initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
//                                                target:[[UIApplication sharedApplication] delegate]
//                                                action:@selector(dismissModalViewController)];
//        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:PIN];
//        navigation.navigationBar.barStyle = UIBarStyleBlack;
//        navigation.definesPresentationContext = YES;
//        [self presentModalViewController:navigation animated:YES];
    }
    
    // questions cell
    else if ([cell.reuseIdentifier isEqualToString:@"ChangeQuestionsCell"]) {
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PINCodeStoryboard" bundle:nil];
//        PINCodeViewController *PIN = [storyboard instantiateViewControllerWithIdentifier:@"PINCodeViewController"];
//        PIN.mode = PINCodeViewControllerModeVerify;
//        PIN.title = @"Enter Passcode";
//        PIN.messageText = @"Enter your passcode";
//        PIN.errorText = @"Incorrect passcode";
//        PIN.delegate = (HRAppDelegate *)[[UIApplication sharedApplication] delegate];
//        PIN.userInfo = @"change_questions";
//        PIN.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
//                                                initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
//                                                target:[[UIApplication sharedApplication] delegate]
//                                                action:@selector(dismissModalViewController)];
//        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:PIN];
//        navigation.navigationBar.barStyle = UIBarStyleBlack;
//        navigation.definesPresentationContext = YES;
//        
//        // show
//        UIViewController *controller = self.presentingViewController;
//        [self dismissViewControllerAnimated:YES completion:^{
//            [controller presentModalViewController:navigation animated:YES];
//        }];
        
    }

}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
}


@end
