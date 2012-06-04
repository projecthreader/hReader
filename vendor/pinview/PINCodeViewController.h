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
 
 Delegatation.
 
 */
@property (nonatomic, assign) IBOutlet id<PINCodeViewControllerDelegate> delegate;
@property (nonatomic, assign) SEL action;

/*
 
 User interface properties.
 
 */
@property (nonatomic, copy) IBOutletCollection(UIButton) NSArray *buttons;
@property (nonatomic, weak) IBOutlet UILabel *passcodeLabel;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UILabel *errorLabel;
- (IBAction)deleteButtonTap;
- (IBAction)numberButtonTap:(UIButton *)sender;

@end
