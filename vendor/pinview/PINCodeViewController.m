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

@property (nonatomic, retain) NSMutableString *mutableInputText;
@property (nonatomic, copy) NSString *inputText;

- (void)clearIfNeeded;
- (void)updatePasscodeLabel;
- (void)passcodeTextDidChange;
- (void)cleanupView;

@end

@implementation PINCodeViewController

@synthesize delegate = __delegate;
@synthesize mutableInputText = __inputTextOne;
@synthesize inputText = __inputTextTwo;
@synthesize mode = __mode;

@synthesize buttons = __buttons;
@synthesize passcodeLabel = __passcodeLabel;
@synthesize messageLabel = __messageLabel;
@synthesize errorLabel = __errorLabel;

@synthesize messageText = __messageText;
@synthesize confirmText = __confirmText;
@synthesize errorText = __errorText;
@synthesize userInfo = __userInfo;

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        clearOnNextInput = NO;
        __mode = 0;
    }
    return self;
}

- (void)dealloc {
    self.messageText = nil;
    self.confirmText = nil;
    self.userInfo = nil;
    [self cleanupView];
    [super dealloc];
}

- (void)clearIfNeeded {
    if (clearOnNextInput) {
        clearOnNextInput = NO;
        self.errorLabel.hidden = YES;
        self.mutableInputText = [NSMutableString string];
        self.inputText = nil;
    }
}

- (void)cleanupView {
    self.buttons = nil;
    self.passcodeLabel = nil;
    self.messageLabel = nil;
    self.errorLabel = nil;
    self.mutableInputText = nil;
    self.inputText = nil;
}

- (void)updatePasscodeLabel {
    NSMutableString *string = [NSMutableString string];
    for (NSUInteger i = 0; i < [self.mutableInputText length]; i++) {
        [string appendString:@"•"];
    }
    self.passcodeLabel.text = string;
}

- (void)passcodeTextDidChange {
    [self updatePasscodeLabel];
    if ([self.mutableInputText length] == [self.delegate PINCodeLength]) {
        if (self.mode == PINCodeViewControllerModeCreate) {
            if (self.inputText == nil) {
                self.inputText = self.mutableInputText;
                self.mutableInputText = [NSMutableString string];
                if (self.confirmText) {
                    self.messageLabel.text = self.confirmText;
                }
                [self updatePasscodeLabel];
            }
            else {
                clearOnNextInput = YES;
                if ([self.mutableInputText isEqualToString:self.inputText]) {
                    [self.delegate PINCodeViewController:self didCreatePIN:self.inputText];
                }
                else {
                    self.messageLabel.text = self.messageText;
                    self.mutableInputText = [NSMutableString string];
                    self.inputText = nil;
                    self.errorLabel.text = self.errorText;
                    self.errorLabel.hidden = NO;
                    [self updatePasscodeLabel];
                }
            }
        }
        else {
            clearOnNextInput = YES;
            if (![self.delegate PINCodeViewController:self isValidPIN:self.mutableInputText]) {
                self.errorLabel.text = self.errorText;
                self.errorLabel.hidden = NO;
                self.mutableInputText = [NSMutableString string];
                [self updatePasscodeLabel];
            }
        }
    }
}

- (void)setMode:(PINCodeViewControllerMode)mode {
    NSAssert((mode > 0 && mode < 3), @"%d is an invalid mode", mode);
    if (__mode == 0) {
        __mode = mode;
    }
}

#pragma mark - button actions

- (IBAction)deleteButtonTap {
    [self clearIfNeeded];
    NSUInteger length = [self.mutableInputText length];
    if (length) {
        NSRange range = NSMakeRange(length - 1, 1);
        [self.mutableInputText deleteCharactersInRange:range];
    }
    [self passcodeTextDidChange];
}

- (IBAction)numberButtonTap:(UIButton *)sender {
    [self clearIfNeeded];
    NSAssert(sender, @"No sender was provided");
    [self.mutableInputText appendString:sender.currentTitle];
    [self passcodeTextDidChange];
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSAssert(__mode > 0, @"No mode has been set");
    
    // self
    UIImage *backgroundImage = [UIImage imageNamed:@"PINCodeBackground"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    clearOnNextInput = YES;
    [self clearIfNeeded];
    [self updatePasscodeLabel];
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
