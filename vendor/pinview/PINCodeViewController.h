//
//  PINCodeViewController.h
//
//  Created by Caleb Davenport on 2/1/12.
//  Copyright (c) 2012 MITRE. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PINCodeViewController;

@protocol PINCodeViewControllerDelegate <NSObject>

- (NSUInteger)PINCodeLength;

- (void)PINCodeViewController:(PINCodeViewController *)controller didSubmitPIN:(NSString *)PIN;

- (void)PINCodeViewControllerDidCancel:(PINCodeViewController *)controller;

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
 
 Refer to `PINCodeViewControllerMode`. This can only be set through the
 designated initializer. Set this value before the view is loaded (before you
 present the view).
 
 */
@property (nonatomic, assign) PINCodeViewControllerMode mode;

/*
 
 Delegate.
 
 */
@property (nonatomic, assign) IBOutlet id<PINCodeViewControllerDelegate> delegate;

/*
 
 User info.
 
 */
@property (nonatomic, copy) NSString *userInfo;

/*
 
 User interface properties.
 
 */
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *buttons;
@property (nonatomic, retain) IBOutlet UILabel *passcodeLabel;
@property (nonatomic, retain) IBOutlet UILabel *messageLabel;
@property (nonatomic, retain) IBOutlet UILabel *errorLabel;
- (IBAction)deleteButtonTap;
- (IBAction)numberButtonTap:(UIButton *)sender;

@end
