//
//  HRAboutTableViewController.m
//  HReader
//
//  Created by Marshall Huss on 12/12/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "HRAboutTableViewController.h"
#import "HRPasscodeWarningViewController.h"
#import "HRAppDelegate.h"
#import "HRPasscodeViewController.h"
#import "HRAPIClient_private.h"

#import "GCAlertView.h"

#import "CMDActivityHUD.h"

#import "HRMPatient.h"

#if !__has_feature(objc_arc)
#error This class requires ARC
#endif

@implementation HRAboutTableViewController

@synthesize versionLabel = _versionLabel;
@synthesize buildDateLabel = _buildDateLabel;

#pragma mark - button actions

- (IBAction)done {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.versionLabel.text = [HRConfig formattedVersion];
    self.buildDateLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CMDBundleBuildTime"];
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
    
    // pop to root
    else if ([cell.reuseIdentifier isEqualToString:@"ManageFamilyCell"]) {
        double delay = 0.25;
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^(void) {
            UIApplication *app = [UIApplication sharedApplication];
            HRAppDelegate *delegate = (id)app.delegate;
            [delegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
        });
    }
    
    // passcode cell
    else if ([cell.reuseIdentifier isEqualToString:@"ChangePasscodeCell"]) {
        [self presentPasscodeVerificationControllerWithAction:@selector(verifyPasscodeOnPasscodeChange::)];
    }
    
    // questions cell
    else if ([cell.reuseIdentifier isEqualToString:@"ChangeQuestionsCell"]) {
        [self presentPasscodeVerificationControllerWithAction:@selector(verifyPasscodeOnQuestionsChange::)];
    }
    
    // logout cell
    else if ([cell.reuseIdentifier isEqualToString:@"RHExLogoutCell"]) {
        GCAlertView *alert = [[GCAlertView alloc]
                              initWithTitle:@"Logout"
                              message:@"This will delete all data synced with RHEx and cannot be undone."];
        [alert addButtonWithTitle:@"Cancel" block:nil];
        [alert addButtonWithTitle:@"Logout" block:^{
            [CMDActivityHUD show];
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                
                // destroy client
                NSString *host = [[HRAPIClient hosts] lastObject];
                HRAPIClient *client = [HRAPIClient clientWithHost:host];
                [client destroy];
                
                // destroy patients
                NSManagedObjectContext *context = [HRAppDelegate managedObjectContext];
                NSFetchRequest *request = [HRMPatient fetchRequestInContext:context];
                [request setIncludesPropertyValues:NO];
                [request setIncludesSubentities:NO];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"host == %@", host];
                [request setPredicate:predicate];
                NSArray *matching = [context executeFetchRequest:request error:nil];
                [matching enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [context deleteObject:obj];
                }];
                [context save:nil];
                
                // clear ui
                [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
                [(id)self.view.window.rootViewController popToRootViewControllerAnimated:NO];
                HRAppDelegate *delegate = (id)[[UIApplication sharedApplication] delegate];
                [delegate performSelector:@selector(performLaunchSteps)];
                
            });
        }];
        [alert setCancelButtonIndex:0];
        [alert show];
    }

}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - private

- (void)presentPasscodeVerificationControllerWithAction:(SEL)action {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"InitialSetup_iPad" bundle:nil];
    HRPasscodeViewController *passcode = [storyboard instantiateViewControllerWithIdentifier:@"VerifyPasscodeViewController"];
    passcode.mode = HRPasscodeViewControllerModeVerify;
    passcode.target = [[UIApplication sharedApplication] delegate];
    passcode.action = action;
    passcode.title = @"Enter Passcode";
    passcode.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithTitle:@"Next"
                                                  style:UIBarButtonItemStyleDone
                                                  target:passcode
                                                  action:@selector(verify:)];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:passcode];
    UIViewController *presenting = self.presentingViewController;
    [presenting dismissViewControllerAnimated:YES completion:^{
        [presenting presentViewController:navigation animated:YES completion:nil];
    }];
}

@end
