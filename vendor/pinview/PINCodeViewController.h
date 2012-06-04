//
//  PINCodeViewController.h
//
//  Created by Caleb Davenport on 2/1/12.
//  Copyright (c) 2012 MITRE. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PINCodeViewController;

@protocol PINCodeViewControllerDelegate <NSObject>

@required

/*
 
 This determines how long the user input must be before the pin code controller
 tries to verify the data with the delegate and inidicate success or error.
 
 */
- (NSUInteger)PINCodeLength;

@end

typedef enum {
    
    /*
     
     Create a new passcode. This allows the user to enter a new passcode then
     imediately verify it.
     
     */
    PINCodeViewControllerModeCreate = 1,
    
    /*
     
     Verify a passcode. This allows the user to input a passcode then have it
     checked by the caller.
     
     */
    PINCodeViewControllerModeVerify
    
} PINCodeViewControllerMode;

@interface PINCodeViewController : UIViewController

/*
 
 The message to display text above the input area. Set these values before the
 view is loaded (before you present the view).
 
 */
@property (nonatomic, copy) NSString *messageText;
@property (nonatomic, copy) NSString *confirmText;

/*
 
 The message to display if user input is invalid.
 
 */
@property (nonatomic, copy) NSString *errorText;

/*
 
 Refer to `PINCodeViewControllerMode`. This can only be set through the
 designated initializer. Set this value before the view is loaded (before you
 present the view).
 
 */
@property (nonatomic, assign) PINCodeViewControllerMode mode;

/*
 
 Delegation methods. The delegate must implement the 
 `PINCodeViewControllerDelegate` protocol. The action provided can be any
 method that takes two parameters. The first of these parameters is an instance
 of `PINCodeViewController` and the second is the passcode itself. The return
 value of this method can be `void` while the pin code controller is in create
 mode as it is ignored. The return value in verify mode is used to control
 the error behavior of the pin code controller so it should be a `BOOL`.
 
 */
@property (nonatomic, assign) IBOutlet id<PINCodeViewControllerDelegate> delegate;
@property (nonatomic, assign) SEL action;

// internal
@property (nonatomic, copy) IBOutletCollection(UIButton) NSArray *buttons;
@property (nonatomic, weak) IBOutlet UILabel *passcodeLabel;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UILabel *errorLabel;
- (IBAction)deleteButtonTap;
- (IBAction)numberButtonTap:(UIButton *)sender;

@end
