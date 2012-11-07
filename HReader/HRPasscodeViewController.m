//
//  HRPasscodeViewController.m
//  HReader
//
//  Created by Caleb Davenport on 6/8/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRPasscodeViewController.h"

@implementation HRPasscodeViewController

#pragma mark - class methods

+ (BOOL)doesPasscodeMeetPolicy:(NSString *)passcode {
    NSString *pattern = @"^.*(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.{8,}).*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    return [predicate evaluateWithObject:passcode];
}

#pragma mak - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _mode = 0;
    }
    return self;
}

- (void)setMode:(HRPasscodeViewControllerMode)mode {
    NSAssert((mode > 0 && mode < 3), @"%d is an invalid mode", mode);
    if (_mode == 0) { _mode = mode; }
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSAssert(self.mode, @"No mode has been set");
    NSAssert(self.target, @"No target has been set");
    NSAssert(self.action, @"No action has been set");
    
    // shadows
    CALayer *layer = self.passcodeOneField.superview.layer;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOffset = CGSizeMake(0.0, 0.0);
    layer.shadowOpacity = 0.1;
    layer.shadowRadius = 5.0;
    layer.borderColor = [[UIColor colorWithWhite:0.79 alpha:1.0] CGColor];
    layer.borderWidth = 1.0;
    layer.cornerRadius = 10.0;
    layer = self.dividerView.layer;
    layer.shadowColor = [[UIColor whiteColor] CGColor];
    layer.shadowOffset = CGSizeMake(0.0, 1.0);
    layer.shadowOpacity = 0.5;
    layer.shadowRadius = 0.0;
    
    // other stuff
    [self.passcodeOneField becomeFirstResponder];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - button actions

- (IBAction)verify:(UIBarButtonItem *)sender {
    NSAssert(self.mode == HRPasscodeViewControllerModeVerify, @"The controller must be in verify mode");
    NSString *passcode = self.passcodeOneField.text;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    BOOL valid = (BOOL)[self.target performSelector:self.action withObject:self withObject:passcode];
#pragma clang diagnostic pop
    if (!valid) {
        self.passcodeOneField.text = nil;
    }
}

- (IBAction)create:(UIBarButtonItem *)sender {
    NSAssert(self.mode == HRPasscodeViewControllerModeCreate, @"The controller must be in create mode");
    NSString *passcode = self.passcodeOneField.text;
    if ([passcode isEqualToString:self.passcodeTwoField.text]) {
        if ([HRPasscodeViewController doesPasscodeMeetPolicy:passcode]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.target performSelector:self.action withObject:self withObject:passcode];
#pragma clang diagnostic pop
        }
        else {
            [[[UIAlertView alloc]
              initWithTitle:@"The passcode does not meet security requirements."
              message:nil
              delegate:nil
              cancelButtonTitle:@"OK"
              otherButtonTitles:nil]
             show];
        }
    }
    else {
        [[[UIAlertView alloc]
          initWithTitle:@"The provided passcodes do not match."
          message:nil
          delegate:nil
          cancelButtonTitle:@"OK"
          otherButtonTitles:nil]
         show];
    }
}

#pragma mark - text field methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.mode == HRPasscodeViewControllerModeVerify) {
        [self verify:nil];
    }
    else if (self.mode == HRPasscodeViewControllerModeCreate) {
        if (textField == self.passcodeOneField) {
            [self.passcodeTwoField becomeFirstResponder];
        }
        else {
            [self create:nil];
        }
    }
    return NO;
}

- (IBAction)textFieldTextDidChange:(UITextField *)sender {
    BOOL enabled = NO;
    if (self.mode == HRPasscodeViewControllerModeVerify) {
        enabled = ([self.passcodeOneField.text length] > 0);
    }
    else if (self.mode == HRPasscodeViewControllerModeCreate) {
        enabled = ([self.passcodeOneField.text length] > 0 &&
                   [self.passcodeTwoField.text length] > 0);
    }
    self.navigationItem.rightBarButtonItem.enabled = enabled;
}

@end
