//
//  HRPasscodeWarningViewController.m
//  HReader
//
//  Created by Marshall Huss on 12/16/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "HRPasscodeWarningViewController.h"

@implementation HRPasscodeWarningViewController

@synthesize imageView           = __imageView;
@synthesize confirmButton       = __confirmButton;
@synthesize demoMode            = __demoMode;

- (void)dealloc {
    [__imageView release];
    [__confirmButton release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.demoMode = NO;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.confirmButton.hidden = YES;

    if (self.demoMode) {        
        [self.confirmButton setTitle:@"Dismiss Demo" forState:UIControlStateNormal];
        self.confirmButton.hidden = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPrivacyCheck:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setConfirmButton:nil];
    [super viewDidUnload];
}

- (void)didPrivacyCheck:(NSNotification *)notif {
    if ([HRConfig hasLaunched])  {
        if ([HRConfig passcodeEnabled]) {
            [TestFlight passCheckpoint:@"Passcode Enabled"];
            self.imageView.image = [UIImage imageNamed:@"win"];
            [self.confirmButton setTitle:@"Continue" forState:UIControlStateNormal];
        } else {
            self.imageView.image = [UIImage imageNamed:@"fail"];
            [TestFlight passCheckpoint:@"Passcode NOT Enabled"];
            [self.confirmButton setTitle:@"I understand my privacy isn't protected without a passcode!" forState:UIControlStateNormal];
        }
        
        self.confirmButton.hidden = NO;
        
    } else {
        [HRConfig setHasLaunched:YES];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (IBAction)confirmButtonPressed:(id)sender {
    [TestFlight passCheckpoint:@"Privacy Education Button Pressed"];
    [HRConfig setPrivacyWarningConfirmed:YES];
    [self dismissModalViewControllerAnimated:YES];
}

@end
