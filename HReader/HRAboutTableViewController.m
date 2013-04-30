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
#import "HRAPIClient_private.h"

#import "CMDBlocksKit.h"
#import "CMDActivityHUD.h"

#import "HRMPatient.h"

#import "HRCryptoManager.h"

#import <AppPassword/AppPassword.h>

@interface HRAboutTableViewController ()

@property (nonatomic)        PASS_CTL passControl;
@property (nonatomic)        PASS_CTL passNextStep;

@property (nonatomic,strong) APPass    *appPass;
@property (nonatomic,strong) APPass    *appQuestion;
@property (nonatomic)        NSInteger  numberOfQuestions;


@property (nonatomic, weak) IBOutlet UILabel *versionLabel;
@property (nonatomic, weak) IBOutlet UILabel *buildDateLabel;

@end

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
    //--------------------------------------------------------------------------
    // Setup AppPass API
    //--------------------------------------------------------------------------
    [self initAppAPI];

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
        [self presentPasscodeVerificationControllerWithAction:PASS_CREATE];
    }
    
    // questions cell
    else if ([cell.reuseIdentifier isEqualToString:@"ChangeQuestionsCell"]) {
        [self presentPasscodeVerificationControllerWithAction:PASS_CREATE_Q];
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

- (void)presentPasscodeVerificationControllerWithAction:(PASS_CTL)action {
    
    self.passNextStep = action;

    [self presentPass:PASS_VERIFY];
    /*
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"InitialSetup_iPad" bundle:nil];
    IMSPasswordViewController *password = [storyboard instantiateViewControllerWithIdentifier:@"VerifyPasscodeViewController"];;
    password.target = [[UIApplication sharedApplication] delegate];
    password.action = action;
    password.title = @"Enter Password";
    password.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithTitle:@"Next"
                                                  style:UIBarButtonItemStyleDone
                                                  target:password
                                                  action:@selector(doneButtonAction:)];
    
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:password];
    UIViewController *presenting = self.presentingViewController;
    [presenting dismissViewControllerAnimated:YES completion:^{
        [presenting presentViewController:navigation animated:YES completion:nil];
    }];
     */
}
//------------------------------------------------------------------------------
// APPass
//------------------------------------------------------------------------------
-(void) initAppAPI {
    
    self.numberOfQuestions    = 2;
    
    if ( nil == self.appPass)
    self.appPass              = [APPass
                                 complexPassWithName:@"APComplexPass"
                                 fromStoryboardWithName:@"InitialSetup_iPad"];
    
    if ( nil == self.appQuestion)
    self.appQuestion          = [APPass
                                 passWithName:@"APQuestionPass"
                                 fromStoryboardWithName:@"InitialSetup_iPad"
                                 withQuestions:self.numberOfQuestions];
    self.appPass.delegate     = self;
    self.appQuestion.delegate = self;
    
    self.appPass.syntax       = @"^.*(?=.*[a-zA-Z])(?=.*[0-9])(?=.{8,}).*$";
    
}

//------------------------------------------------------------------------------
// APPass
//------------------------------------------------------------------------------
-(void) presentPass:(PASS_CTL) cntrl {
    
    self.passControl              = cntrl;
    self.appPass.verify           = (cntrl == PASS_VERIFY) ? @"verify" : nil;
    self.appPass.parentController = self.navigationController;
}
-(void) presentQuestion:(PASS_CTL) cntrl {
    
    self.passControl                  = cntrl;
    self.appQuestion.parentController = self.navigationController;
}

//------------------------------------------------------------------------------
// APPassProtocol - required
//------------------------------------------------------------------------------
-(void) APPassComplete:(UIViewController*) viewController
            withPhrase:(NSString*)         phrase {
    
    if ( nil != phrase ) {
        
        switch (self.passControl) {
                
            case PASS_CREATE: [self processCreate:viewController
                                       withPhrase:phrase];
                break;
            case PASS_VERIFY: [self processVerify:viewController
                                       withPhrase:phrase];
                break;
            default: break;
        }
    }
}
//------------------------------------------------------------------------------
// APPassProtocol - verify the entered passcode with the stored one
//------------------------------------------------------------------------------
-(BOOL) verifyPhraseWithSecureFoundation:(NSString*) phrase {
    
    BOOL ret = NO;
    
    if (phrase) ret = HRCryptoManagerUnlockWithPasscode(phrase);
    
    return ret;
}

-(void) resetPassAP {
    
//    [self presentQuestion:PASS_VERIFY_Q];
}

//------------------------------------------------------------------------------
// The new passcode has been entered so update the old 
//------------------------------------------------------------------------------
- (void) processCreate:(UIViewController*) viewController
            withPhrase:(NSString*) phrase {
    
    HRCryptoManagerUpdatePasscode(phrase);
    
    [self done];
}
//------------------------------------------------------------------------------
// The old passcode has been verified, so take the next step
//------------------------------------------------------------------------------
- (void) processVerify:(UIViewController*) viewController
            withPhrase:(NSString*) phrase {
    
    if (HRCryptoManagerUnlockWithPasscode(phrase)) {

        switch (self.passNextStep) {
                
            case PASS_CREATE:   [self presentPass:self.passNextStep];
                break;
            case PASS_CREATE_Q: [self presentQuestion:self.passNextStep];
                break;
            default: break;
        }
    }
}
//------------------------------------------------------------------------------
// APQuestionProtocol - required
//------------------------------------------------------------------------------
-(void) APPassComplete:(UIViewController *) viewController
         withQuestions:(NSArray *)          questions
            andAnswers:(NSArray *)          answers {
    
    if ( nil != questions && nil != answers ) {
        
        HRCryptoManagerUpdateSecurityQuestionsAndAnswers(questions, answers);

        [self done];
    }
}



@end
