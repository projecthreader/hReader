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

#import "CMDBlocksKit.h"
#import "CMDActivityHUD.h"

#import "HRMPatient.h"

@implementation HRAboutTableViewController

#pragma mark - button actions

- (IBAction)done {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.versionLabel.text = [[NSBundle mainBundle] hr_displayVersion];
    self.buildDateLabel.text = [[NSBundle mainBundle] hr_buildTime];
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
            [controller setToRecipients:@[ @"hReader Feedback <hreader@googlegroups.com>" ]];
            [controller setSubject:@"hReader Feedback"];
            [controller
             setMessageBody:[NSString stringWithFormat:
                             @"\n\nApp Version: %@\n",
                             [[NSBundle mainBundle] hr_displayVersion]]
             isHTML:NO];
            [self presentViewController:controller animated:YES completion:nil];
        }
        else {
            NSString *message = [NSString stringWithFormat:
                                 @"No email accounts are configured on this %@. Would you like to add one now?",
                                 [[UIDevice currentDevice] model]];
            CMDAlertView *alert = [[CMDAlertView alloc] initWithTitle:nil message:message];
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
        CMDAlertView *alert = [[CMDAlertView alloc]
                               initWithTitle:@"Logout"
                               message:@"This will delete all data synced with RHEx and cannot be undone."];
        [alert addButtonWithTitle:@"Cancel" block:^{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
        [alert addButtonWithTitle:@"Logout" block:^{
            [CMDActivityHUD show];
            dispatch_time_t oneTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
            dispatch_after(oneTime, dispatch_get_main_queue(), ^(void){
                [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
                [(id)self.view.window.rootViewController popToRootViewControllerAnimated:NO];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
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
                    HRAppDelegate *delegate = (id)[[UIApplication sharedApplication] delegate];
                    [delegate performSelector:@selector(performLaunchSteps)];
                    [CMDActivityHUD dismiss];
                    
                });
            });
        }];
        [alert setCancelButtonIndex:0];
        [alert show];
    }

}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
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
