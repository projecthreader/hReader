//
//  PINCodeViewController.m
//
//  Created by Caleb Davenport on 2/1/12.
//  Copyright (c) 2012 MITRE. All rights reserved.
//

#import "SSKeychain.h"

#import "PINCodeViewController.h"

#define kGCPINViewControllerDelay 0.5

@interface PINCodeViewController ()
@property (nonatomic, retain) NSMutableString *passcodeText;
@property (nonatomic, copy) NSString *secondPasscodeText;
- (void)cleanupView;
- (void)updatePasscodeLabel;
- (void)passcodeTextDidChange;
- (void)wrong;
@end

@implementation PINCodeViewController

@synthesize messageText = __messageText;
@synthesize confirmText = __confirmText;
@synthesize errorText = __errorText;
@synthesize verifyBlock = __verifyBlock;
@synthesize mode = __mode;

@synthesize buttonOne = __buttonOne;
@synthesize buttonTwo = __buttonTwo;
@synthesize buttonThree = __buttonThree;
@synthesize buttonFour = __buttonFour;
@synthesize buttonFive = __buttonFive;
@synthesize buttonSix = __buttonSix;
@synthesize buttonSeven = __buttonSeven;
@synthesize buttonEight = __buttonEight;
@synthesize buttonNine = __buttonNine;
@synthesize buttonTen = __buttonTen;
@synthesize passcodeText = __passcodeText;
@synthesize secondPasscodeText = __secondPasscodeText;
@synthesize passcodeLabel = __passcodeLabel;
@synthesize messageLabel = __messageLabel;
@synthesize errorLabel = __errorLabel;

#pragma mark - object methods
- (void)dealloc {
    self.messageText = nil;
    self.confirmText = nil;
    self.errorText = nil;
    self.verifyBlock = nil;
    [self cleanupView];
    [super dealloc];
}
- (void)cleanupView {
    self.buttonOne = nil;
    self.buttonTwo = nil;
    self.buttonThree = nil;
    self.buttonFour = nil;
    self.buttonFive = nil;
    self.buttonSix = nil;
    self.buttonSeven = nil;
    self.buttonEight = nil;
    self.buttonNine = nil;
    self.buttonTen = nil;
    self.passcodeLabel = nil;
    self.messageLabel = nil;
    self.errorLabel = nil;
    self.passcodeText = nil;
    self.secondPasscodeText = nil;
}
- (void)updatePasscodeLabel {
    NSMutableString *string = [NSMutableString string];
    for (NSUInteger i = 0; i < [self.passcodeText length]; i++) {
        [string appendString:@"•"];
    }
    self.passcodeLabel.text = string;
}
- (void)wrong {
    self.errorLabel.hidden = NO;
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, kGCPINViewControllerDelay * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        self.passcodeText = [NSMutableString string];
        [self updatePasscodeLabel];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });
}
- (void)dismiss {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, kGCPINViewControllerDelay * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [self dismissModalViewControllerAnimated:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });
}
- (void)passcodeTextDidChange {
    self.errorLabel.hidden = YES;
    [self updatePasscodeLabel];
    if ([self.passcodeText length] == 6) {
        if (self.mode == PINCodeViewControllerModeCreate) {
            if (self.secondPasscodeText == nil) {
                self.secondPasscodeText = self.passcodeText;
                self.passcodeText = [NSMutableString string];
                if (self.confirmText) {
                    self.messageLabel.text = self.confirmText;
                }
                [self updatePasscodeLabel];
            }
            else {
                if ([self.passcodeText isEqualToString:self.secondPasscodeText] &&
                    self.verifyBlock(self.passcodeText)) {
                    [self dismiss];
                }
                else {
                    self.messageLabel.text = self.messageText;
                    self.secondPasscodeText = nil;
                    [self wrong];
                }
            }
        }
        else if (self.mode == PINCodeViewControllerModeVerify) {
            if (self.verifyBlock(self.passcodeText)) {
                [self dismiss];
            }
            else {
                [self wrong];
            }
        }
    }
}

#pragma mark - button actions
- (IBAction)deleteButtonTap {
    NSUInteger length = [self.passcodeText length];
    if (length) {
        NSRange range = NSMakeRange(length - 1, 1);
        [self.passcodeText deleteCharactersInRange:range];
    }
    [self passcodeTextDidChange];
}
- (IBAction)numberButtonTap:(UIButton *)sender {
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
    self.errorLabel.text = self.errorText;
    self.messageLabel.text = self.messageText;
    NSAssert(self.verifyBlock, @"No verify block was provided");
    
    // collect buttons
    NSMutableArray *buttons = [NSMutableArray arrayWithObjects:
                               self.buttonOne,
                               self.buttonTwo,
                               self.buttonThree,
                               self.buttonFour,
                               self.buttonFive,
                               self.buttonSix,
                               self.buttonSeven,
                               self.buttonEight,
                               self.buttonNine,
                               self.buttonTen,
                               nil];
    NSUInteger count = [buttons count];
    for (NSUInteger i = 0; i < count; i++) {
        u_int32_t elements = count - i;
        u_int32_t n = (arc4random() % elements) + i;
        [buttons exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    [buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setTitle:[NSString stringWithFormat:@"%lu", (long)idx] forState:UIControlStateNormal];
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

@implementation PINCodeViewController (HRKeychainAdditions)

static NSString * const HRKeychainService = @"org.mitre.hreader";
static NSString * const HRKeychainAccount = @"org.mitre.hreader.account.default";

+ (void)setPersistedPasscode:(NSString *)code {
    [SSKeychain
     setPassword:code
     forService:HRKeychainService
     account:HRKeychainAccount];
}

+ (BOOL)isPasscodeValid:(NSString *)code {
    NSString *keychain = [SSKeychain
                          passwordForService:HRKeychainService
                          account:HRKeychainAccount];
    return [code isEqualToString:keychain];
}

+ (BOOL)isPasscodeSet {
    NSString *keychain = [SSKeychain
                          passwordForService:HRKeychainService
                          account:HRKeychainAccount];
    return (keychain != nil);
}

@end
