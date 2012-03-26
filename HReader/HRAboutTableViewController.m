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

#pragma mark - button actions

//- (void)cancelModalView {
//    [self dismissModalViewControllerAnimated:YES];
//}

#pragma mark - passcode view delegate

//- (NSUInteger)PINCodeLength {
//    return 6;
//}
//
//- (void)PINCodeViewController:(PINCodeViewController *)controller didCreatePIN:(NSString *)PIN {
//    [HRKeychainManager setPasscode:PIN];
//    [controller dismissModalViewControllerAnimated:YES];
//}
//
//- (BOOL)PINCodeViewController:(PINCodeViewController *)controller isValidPIN:(NSString *)PIN {
//    BOOL valid = [HRKeychainManager isPasscodeValid:PIN];
//    if (valid) {
//        
//        // if we are changing passcode
//        if ([controller.userInfo isEqualToString:@"pin"]) {
//            PINCodeViewController *create = [controller.storyboard instantiateViewControllerWithIdentifier:@"PINCodeViewController"];
//            create.mode = PINCodeViewControllerModeCreate;
//            create.title = @"Set Passcode";
//            create.messageText = @"Enter a passcode";
//            create.confirmText = @"Verify passcode";
//            create.errorText = @"The passcodes do not match";
//            create.delegate = (HRAppDelegate *)[[UIApplication sharedApplication] delegate];
//            create.navigationItem.leftBarButtonItem = controller.navigationItem.leftBarButtonItem;
//            [controller.navigationController pushViewController:create animated:YES];
//        }
//        
//        // if we are changing security questions
//        else {
//            PINSecurityQuestionsViewController *questions = [controller.storyboard instantiateViewControllerWithIdentifier:@"SecurityQuestionsController"];
//            questions.navigationItem.hidesBackButton = YES;
//            questions.mode = PINSecurityQuestionsViewControllerEdit;
//            questions.delegate = (HRAppDelegate *)[[UIApplication sharedApplication] delegate];
//            questions.title = @"Security Questions";
//            questions.navigationItem.leftBarButtonItem = controller.navigationItem.leftBarButtonItem;
//            [controller.navigationController pushViewController:questions animated:YES];
//        }
//        
//    }
//    return valid;
//}

#pragma mark - questions controller delegate

//- (NSUInteger)numberOfSecurityQuestions {
//    return 2;
//}
//
//- (NSArray *)securityQuestions {
//    return [HRKeychainManager securityQuestions];
//}
//
//- (void)securityQuestionsController:(PINSecurityQuestionsViewController *)controller didSubmitQuestions:(NSArray *)questions answers:(NSArray *)answers {
//    [HRKeychainManager setSecurityQuestions:questions answers:answers];
//    [controller dismissModalViewControllerAnimated:YES];
//}

@end
