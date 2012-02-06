//
//  PINCodeViewController.h
//
//  Created by Caleb Davenport on 2/1/12.
//  Copyright (c) 2012 MITRE. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    
    /*
     
     Create a new passcode. This allows the user to enter a new passcode then
     imediately verify it.
     
     */
    PINCodeViewControllerModeCreate = 0,
    
    /*
     
     Verify a passcode. This allows the user to input a passcode then have it
     checked by the caller.
     
     */
    PINCodeViewControllerModeVerify
    
} PINCodeViewControllerMode;

/*
 
 Block used to verify a code. Evaluate the code and return `YES` or `NO` to
 indicate the valididty of the code.
 
 */
typedef BOOL (^PINCodeVerifyBlock) (NSString *code);

@interface PINCodeViewController : UIViewController

/*
 
 The message to display text above the input area. Set these values before the
 view is loaded (before you present the view).
 
 */
@property (nonatomic, copy) NSString *messageText;
@property (nonatomic, copy) NSString *confirmText;

/*
 
 The message to display below the input area when the passcode fails
 verification. Set this value before the view is loaded (before you present the
 view).
 
 */
@property (nonatomic, copy) NSString *errorText;

/*
 
 Called when a passcode has passed internal verification and needs to be
 approved for use by the application. When creating a new passcode, this is not
 called until the user has input the same passcode twice. Return YES to signal
 that the passcode meets required standards (when creating a new passcode) or
 that it is correct (when verifying an existing passcode) and NO to signal that
 the user needs to try again. You are free to present alerts in this block
 offering more information to the user.
 
 */
@property (nonatomic, copy) PINCodeVerifyBlock verifyBlock;

/*
 
 Refer to `PINCodeViewControllerMode`. This can only be set through the
 designated initializer. Set this value before the view is loaded (before you
 present the view).
 
 */
@property (nonatomic, assign) PINCodeViewControllerMode mode;

/*
 
 User interface properties.
 
 */
@property (nonatomic, retain) IBOutlet UIButton *buttonOne;
@property (nonatomic, retain) IBOutlet UIButton *buttonTwo;
@property (nonatomic, retain) IBOutlet UIButton *buttonThree;
@property (nonatomic, retain) IBOutlet UIButton *buttonFour;
@property (nonatomic, retain) IBOutlet UIButton *buttonFive;
@property (nonatomic, retain) IBOutlet UIButton *buttonSix;
@property (nonatomic, retain) IBOutlet UIButton *buttonSeven;
@property (nonatomic, retain) IBOutlet UIButton *buttonEight;
@property (nonatomic, retain) IBOutlet UIButton *buttonNine;
@property (nonatomic, retain) IBOutlet UIButton *buttonTen;
@property (nonatomic, retain) IBOutlet UILabel *passcodeLabel;
@property (nonatomic, retain) IBOutlet UILabel *messageLabel;
@property (nonatomic, retain) IBOutlet UILabel *errorLabel;
- (IBAction)deleteButtonTap;
- (IBAction)numberButtonTap:(UIButton *)sender;

@end

@interface PINCodeViewController (HRKeychainAdditions)

#if defined (DEBUG) || defined (DEVELOPMENT)
+ (void)resetPersistedPasscode;
#endif
+ (void)setPersistedPasscode:(NSString *)code;
+ (BOOL)isPasscodeValid:(NSString *)code;
+ (BOOL)isPersistedPasscodeSet;

@end
