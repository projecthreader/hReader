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
        PIN.delegate = self;
        PIN.userInfo = @"pin";
        PIN.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                target:self
                                                action:@selector(cancelModalView)];
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:PIN];
        navigation.navigationBar.barStyle = UIBarStyleBlack;
        navigation.definesPresentationContext = YES;
        [self presentModalViewController:navigation animated:YES];
        
        
        
        
        
        
        
//        // get storyboard
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PINCodeStoryboard" bundle:nil];
//        
//        // load up view controller
//        UINavigationController *verifyNavigation = [storyboard instantiateInitialViewController];
//        PINCodeViewController *verifyController = [verifyNavigation.viewControllers objectAtIndex:0];
//        verifyController.mode = PINCodeViewControllerModeVerify;
//        verifyController.title = @"Enter Passcode";
//        verifyController.messageText = @"Enter your passcode";
//        verifyController.errorText = @"Incorrect passcode";
//        verifyController.automaticallyDismissWhenValid = NO;
//        verifyController.verifyBlock = ^(NSString *code) {
//            if ([PINCodeViewController isPasscodeValid:code]) {
//                
//                // load up create controller
//                UINavigationController *createNavigation = [storyboard instantiateInitialViewController];
//                PINCodeViewController *createController = [createNavigation.viewControllers objectAtIndex:0];
//                creatreeController.mode = PINCodeViewControllerModeCreate;
//                createController.title = @"Set Passcode";
//                createController.messageText = @"Enter a passcode";
//                createController.confirmText = @"Verify passcode";
//                createController.errorText = @"The passcodes do not match";
//                createController.automaticallyDismissWhenValid = NO;
//                createController.verifyBlock = ^(NSString *code) {
//                    if ([code length] == 6) {
//                        [PINCodeViewController setPersistedPasscode:code];
//                        [self dismissModalViewControllerAnimated:YES];
//                        return YES;
//                    }
//                    else {
//                        return NO;
//                    }
//                };
//                [verifyController presentModalViewController:createNavigation animated:NO];
//                
//                // return
//                return YES;
//                
//            }
//            else {
//                return NO;
//            }
//        };
//        [self presentModalViewController:verifyNavigation animated:YES];
    }
    else if ([cell.reuseIdentifier isEqualToString:@"ChangeQuestionsCell"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PINCodeStoryboard" bundle:nil];
        PINCodeViewController *PIN = [storyboard instantiateViewControllerWithIdentifier:@"PINCodeViewController"];
        PIN.mode = PINCodeViewControllerModeVerify;
        PIN.title = @"Enter Passcode";
        PIN.messageText = @"Enter your passcode";
        PIN.delegate = self;
        PIN.userInfo = @"questions";
        PIN.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                target:self
                                                action:@selector(cancelModalView)];
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:PIN];
        navigation.navigationBar.barStyle = UIBarStyleBlack;
        navigation.definesPresentationContext = YES;
        [self presentModalViewController:navigation animated:YES];
    }

}

#pragma mark - button actions

- (void)cancelModalView {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - passcode view delegate

- (NSUInteger)PINCodeLength {
    return 6;
}

- (void)PINCodeViewController:(PINCodeViewController *)controller didSubmitPIN:(NSString *)PIN {
    if (controller.mode == PINCodeViewControllerModeVerify) {
        if ([HRKeychainManager isPasscodeValid:PIN]) {
            
            // if we are changing passcode
            if ([controller.userInfo isEqualToString:@"pin"]) {
                PINCodeViewController *create = [controller.storyboard instantiateViewControllerWithIdentifier:@"PINCodeViewController"];
                create.mode = PINCodeViewControllerModeCreate;
                create.title = @"Set Passcode";
                create.messageText = @"Enter a passcode";
                create.confirmText = @"Verify passcode";
                create.delegate = self;
                create.navigationItem.leftBarButtonItem = controller.navigationItem.leftBarButtonItem;
                [controller.navigationController pushViewController:create animated:YES];
            }
            
            // if we are changing security questions
            else {
                PINSecurityQuestionsViewController *questions = [controller.storyboard instantiateViewControllerWithIdentifier:@"SecurityQuestionsController"];
                questions.navigationItem.hidesBackButton = YES;
                questions.mode = PINSecurityQuestionsViewControllerEdit;
                questions.delegate = self;
                questions.title = @"Security Questions";
                questions.navigationItem.leftBarButtonItem = controller.navigationItem.leftBarButtonItem;
                [controller.navigationController pushViewController:questions animated:YES];
            }
            
        }
        else {
            controller.errorLabel.text = @"Incorrect passcode";
            controller.errorLabel.hidden = NO;
        }
    }
    else {
        [HRKeychainManager setPasscode:PIN];
        [controller dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - questions controller delegate

- (NSUInteger)numberOfSecurityQuestions {
    return 2;
}

- (NSArray *)securityQuestions {
    return [HRKeychainManager securityQuestions];
}

- (void)securityQuestionsController:(PINSecurityQuestionsViewController *)controller didSubmitQuestions:(NSArray *)questions answers:(NSArray *)answers {
    [HRKeychainManager setSecurityQuestions:questions answers:answers];
    [controller dismissModalViewControllerAnimated:YES];
}

@end
