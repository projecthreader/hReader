//
//  PINCodeViewController.m
//
//  Created by Caleb Davenport on 2/1/12.
//  Copyright (c) 2012 MITRE. All rights reserved.
//

#import "SSKeychain.h"

#import "PINCodeViewController.h"

#define kGCPINViewControllerDelay 0.5

static NSString * const HRUUID = @"KeychainUUID";

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
@synthesize automaticallyDismissWhenValid = __automaticallyDismissWhenValid;

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

#pragma mark - class methods

+ (void)initialize {
    if (self == [PINCodeViewController class]) {
        
        // check for existing uuid
        NSString *UUID = [[NSUserDefaults standardUserDefaults] objectForKey:HRUUID];
        
        // create one if none exists
        if (UUID == nil) {
            CFUUIDRef UUIDRef = CFUUIDCreate(kCFAllocatorDefault);
            CFStringRef UUIDStringRef = CFUUIDCreateString(kCFAllocatorDefault, UUIDRef);
            CFRelease(UUIDRef);
            UUID = [(NSString *)UUIDStringRef autorelease];
            [[NSUserDefaults standardUserDefaults] setObject:UUID forKey:HRUUID];
        }
        
    }
}

#pragma mark - object methods
- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.automaticallyDismissWhenValid = YES;
    }
    return self;
}
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
    if (self.automaticallyDismissWhenValid) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, kGCPINViewControllerDelay * NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^(void){
            [self dismissModalViewControllerAnimated:YES];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        });
    }
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
static NSString * const HRKeychainPINAccount = @"account.pin";
static NSString * const HRKeychainSecurityQuestionsAccount = @"account.security_questions";

+ (NSString *)accountNameWithType:(NSString *)type {
    NSString *UUID = [[NSUserDefaults standardUserDefaults] objectForKey:HRUUID];
    return [UUID stringByAppendingPathExtension:type];
}

+ (void)setPersistedPasscode:(NSString *)code {
    [SSKeychain
     setPassword:code
     forService:HRKeychainService
     account:[self accountNameWithType:HRKeychainPINAccount]];
}

+ (BOOL)isPasscodeValid:(NSString *)code {
    NSString *keychain = [SSKeychain
                          passwordForService:HRKeychainService
                          account:[self accountNameWithType:HRKeychainPINAccount]];
    return [code isEqualToString:keychain];
}

+ (BOOL)isPersistedPasscodeSet {
    NSString *keychain = [SSKeychain
                          passwordForService:HRKeychainService
                          account:[self accountNameWithType:HRKeychainPINAccount]];
    return (keychain != nil);
}

+ (void)setAnswersForSecurityQuestions:(NSArray *)answers {
    NSString *code = [answers componentsJoinedByString:@""];
    [SSKeychain
     setPassword:code
     forService:HRKeychainService
     account:[self accountNameWithType:HRKeychainSecurityQuestionsAccount]];
}

+ (BOOL)areAnswersForSecurityQuestionsValid:(NSArray *)answers {
    NSString *code = [answers componentsJoinedByString:@""];
    NSString *keychain = [SSKeychain
                          passwordForService:HRKeychainService
                          account:[self accountNameWithType:HRKeychainSecurityQuestionsAccount]];
    return ([code compare:keychain options:NSCaseInsensitiveSearch] == NSOrderedSame);
}

@end
