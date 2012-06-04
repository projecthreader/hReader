//
//  PINCodeViewController.m
//
//  Created by Caleb Davenport on 2/1/12.
//  Copyright (c) 2012 MITRE. All rights reserved.
//

#import "SSKeychain.h"

#import "PINCodeViewController.h"

#define kGCPINViewControllerDelay 0.5

#if !__has_feature(objc_arc)
#error This class requires ARC
#endif

@interface PINCodeViewController () {
    BOOL clearOnNextInput;
    NSMutableString *mutableInputText;
    NSString *inputText;
}

- (void)clearIfNeeded;
- (void)updatePasscodeLabel;
- (void)passcodeTextDidChange;

@end

@implementation PINCodeViewController

@synthesize messageText = _messageText;
@synthesize confirmText = _confirmText;
@synthesize errorText = _errorText;

@synthesize mode = _mode;

@synthesize delegate = _delegate;
@synthesize action = _action;

@synthesize buttons = _buttons;
@synthesize passcodeLabel = _passcodeLabel;
@synthesize messageLabel = _messageLabel;
@synthesize errorLabel = _errorLabel;

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        clearOnNextInput = NO;
        _mode = 0;
    }
    return self;
}

- (void)clearIfNeeded {
    if (clearOnNextInput) {
        clearOnNextInput = NO;
        self.errorLabel.hidden = YES;
        mutableInputText = [NSMutableString string];
        inputText = nil;
    }
}

- (void)updatePasscodeLabel {
    NSMutableString *string = [NSMutableString string];
    for (NSUInteger i = 0; i < [mutableInputText length]; i++) {
        [string appendString:@"•"];
    }
    self.passcodeLabel.text = string;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)passcodeTextDidChange {
    UIApplication *app = [UIApplication sharedApplication];
    [self updatePasscodeLabel];
    if ([mutableInputText length] == [self.delegate PINCodeLength]) {
        [app beginIgnoringInteractionEvents];
        double delay = 0.25;
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^(void) {
            if (self.mode == PINCodeViewControllerModeCreate) {
                if (inputText == nil) {
                    inputText = [mutableInputText copy];
                    mutableInputText = [NSMutableString string];
                    if (self.confirmText) { self.messageLabel.text = self.confirmText; }
                    [self updatePasscodeLabel];
                }
                else {
                    clearOnNextInput = YES;
                    if ([mutableInputText isEqualToString:inputText]) {
                        [self.delegate performSelector:self.action withObject:self withObject:inputText];
                    }
                    else {
                        self.messageLabel.text = self.messageText;
                        mutableInputText = [NSMutableString string];
                        inputText = nil;
                        self.errorLabel.text = self.errorText;
                        self.errorLabel.hidden = NO;
                        [self updatePasscodeLabel];
                    }
                }
            }
            else {
                clearOnNextInput = YES;
                if (![self.delegate performSelector:self.action withObject:self withObject:[mutableInputText copy]]) {
                    self.errorLabel.text = self.errorText;
                    self.errorLabel.hidden = NO;
                    mutableInputText = [NSMutableString string];
                    [self updatePasscodeLabel];
                }
            }
            [app endIgnoringInteractionEvents];
        });
    }
}
#pragma clang diagnostic pop

- (void)setMode:(PINCodeViewControllerMode)mode {
    NSAssert((mode > 0 && mode < 3), @"%d is an invalid mode", mode);
    if (_mode == 0) { _mode = mode; }
}

#pragma mark - button actions

- (IBAction)deleteButtonTap {
    [self clearIfNeeded];
    NSUInteger length = [mutableInputText length];
    if (length) {
        NSRange range = NSMakeRange(length - 1, 1);
        [mutableInputText deleteCharactersInRange:range];
    }
    [self passcodeTextDidChange];
}

- (IBAction)numberButtonTap:(UIButton *)sender {
    [self clearIfNeeded];
    NSAssert(sender, @"No sender was provided");
    [mutableInputText appendString:sender.currentTitle];
    [self passcodeTextDidChange];
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSAssert(self.mode > 0, @"No mode has been set");
    NSAssert(self.action, @"No action has been set");
    NSAssert(self.delegate, @"No delegate has been set");
    
    // self
    UIImage *backgroundImage = [UIImage imageNamed:@"PINCodeBackground"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    clearOnNextInput = YES;
    [self clearIfNeeded];
    [self updatePasscodeLabel];
    self.messageLabel.text = self.messageText;
    
    // collect buttons
    NSMutableArray *array = [self.buttons mutableCopy];
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
    self.buttons = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return YES;
}

@end
