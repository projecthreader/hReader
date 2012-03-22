//
//  PINCodeViewController.m
//
//  Created by Caleb Davenport on 2/1/12.
//  Copyright (c) 2012 MITRE. All rights reserved.
//

#import "SSKeychain.h"

#import "PINCodeViewController.h"

#define kGCPINViewControllerDelay 0.5



@interface PINCodeViewController () {
    BOOL clearOnNextInput;
}

@property (nonatomic, retain) NSMutableString *passcodeText;
@property (nonatomic, copy) NSString *confirmPasscodeText;

- (void)clearIfNeeded;
- (void)updatePasscodeLabel;
- (void)passcodeTextDidChange;
- (void)cleanupView;

//- (void)wrong;

@end

@implementation PINCodeViewController

@synthesize delegate = __delegate;
@synthesize buttons = __buttons;
@synthesize passcodeText = __passcodeText;
@synthesize confirmPasscodeText = __confirmPasscodeText;

@synthesize passcodeLabel = __passcodeLabel;
@synthesize messageLabel = __messageLabel;
@synthesize errorLabel = __errorLabel;

@synthesize messageText = __messageText;
@synthesize confirmText = __confirmText;
@synthesize mode = __mode;

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        clearOnNextInput = NO;
    }
    return self;
}

- (void)dealloc {
    self.messageText = nil;
    self.confirmText = nil;
    [self cleanupView];
    [super dealloc];
}

- (void)clearIfNeeded {
    if (clearOnNextInput) {
        clearOnNextInput = NO;
        self.passcodeText = nil;
        self.confirmText = nil;
        self.messageLabel.text = self.messageText;
    }
}

- (void)cleanupView {
    self.buttons = nil;
    self.passcodeLabel = nil;
    self.messageLabel = nil;
    self.errorLabel = nil;
    self.passcodeText = nil;
    self.confirmText = nil;
}

- (void)updatePasscodeLabel {
    NSMutableString *string = [NSMutableString string];
    for (NSUInteger i = 0; i < [self.passcodeText length]; i++) {
        [string appendString:@"•"];
    }
    self.passcodeLabel.text = string;
}

//- (void)wrong {
//    self.errorLabel.hidden = NO;
//    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
//    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, kGCPINViewControllerDelay * NSEC_PER_SEC);
//    dispatch_after(time, dispatch_get_main_queue(), ^(void){
//        self.passcodeText = [NSMutableString string];
//        [self updatePasscodeLabel];
//        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
//    });
//}
//
//- (void)dismiss {
////    if (self.automaticallyDismissWhenValid) {
////        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
////        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, kGCPINViewControllerDelay * NSEC_PER_SEC);
////        dispatch_after(time, dispatch_get_main_queue(), ^(void){
////            [self dismissModalViewControllerAnimated:YES];
////            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
////        });
////    }
//}

- (void)passcodeTextDidChange {
    self.errorLabel.hidden = YES;
    [self updatePasscodeLabel];
    if ([self.passcodeText length] == [self.delegate PINCodeLength]) {
        if (self.mode == PINCodeViewControllerModeCreate) {
            if (self.confirmText == nil) {
                self.confirmText = self.passcodeText;
                self.passcodeText = [NSMutableString string];
                if (self.confirmText) {
                    self.messageLabel.text = self.confirmText;
                }
                [self updatePasscodeLabel];
            }
            else {
                if ([self.passcodeText isEqualToString:self.confirmText]) {
                    clearOnNextInput = YES;
                    [self.delegate PINCodeViewController:self didSubmitPIN:self.passcodeText];
                }
            }
        }
        else {
            clearOnNextInput = YES;
            [self.delegate PINCodeViewController:self didSubmitPIN:self.passcodeText];
        }
    }
}

#pragma mark - button actions

- (IBAction)deleteButtonTap {
    [self clearIfNeeded];
    NSUInteger length = [self.passcodeText length];
    if (length) {
        NSRange range = NSMakeRange(length - 1, 1);
        [self.passcodeText deleteCharactersInRange:range];
    }
    [self passcodeTextDidChange];
}

- (IBAction)numberButtonTap:(UIButton *)sender {
    [self clearIfNeeded];
    NSAssert(sender, @"No sender was provided");
    [self.passcodeText appendString:sender.currentTitle];
    [self passcodeTextDidChange];
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // self
    UIImage *backgroundImage = [UIImage imageNamed:@"PINCodeBackground"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    self.errorLabel.hidden = YES;
    [self updatePasscodeLabel];
    self.passcodeText = [NSMutableString string];
    self.messageLabel.text = self.messageText;
    
    // collect buttons
    NSMutableArray *array = [[self.buttons mutableCopy] autorelease];
    NSUInteger count = [array count];
    for (NSUInteger i = 0; i < count; i++) {
        u_int32_t elements = count - i;
        u_int32_t n = (arc4random() % elements) + i;
        [array exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    [array enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger index, BOOL *stop) {
        [button setTitle:[NSString stringWithFormat:@"%lu", (long)index] forState:UIControlStateNormal];
    }];
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self cleanupView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return YES;
}

@end
