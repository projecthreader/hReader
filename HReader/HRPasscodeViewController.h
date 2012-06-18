//
//  HRPasscodeViewController.h
//  HReader
//
//  Created by Caleb Davenport on 6/8/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    
    /*
     
     Create a new passcode. This allows the user to enter a new passcode then
     imediately verify it.
     
     */
    HRPasscodeViewControllerModeCreate = 1,
    
    /*
     
     Verify a passcode. This allows the user to input a passcode then have it
     checked by the caller.
     
     */
    HRPasscodeViewControllerModeVerify
    
} HRPasscodeViewControllerMode;

@interface HRPasscodeViewController : UIViewController <UITextFieldDelegate>

/*
 
 Refer to `HRPasscodeViewControllerMode`.Set this value before the view is
 loaded (before you present the view).
 
 */
@property (nonatomic, assign) HRPasscodeViewControllerMode mode;

/*
 
 Target action pair that allows the caller to to perform actions with the
 provided passcode. The action provided can be any method that takes two
 parameters. The first of these parameters is an instance of
 `HRPasscodeViewController` and the second is the passcode itself. The return
 value of this method can be `void` while the controller is in create mode as
 it is ignored. The return value in verify mode is used to control the error
 behavior so it should be a `BOOL`.
 
 */
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;

/*
 
 User interface resources.
 
 */
@property (nonatomic, weak) IBOutlet UIView *dividerView;
@property (nonatomic, weak) IBOutlet UITextField *passcodeOneField;
@property (nonatomic, weak) IBOutlet UITextField *passcodeTwoField;
- (IBAction)textFieldTextDidChange:(UITextField *)sender;
- (IBAction)create:(UIBarButtonItem *)sender;
- (IBAction)verify:(UIBarButtonItem *)sender;

@end
