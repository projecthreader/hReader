//
//  HRPasscodeWarningViewController.m
//  HReader
//
//  Created by Marshall Huss on 12/16/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "HRPasscodeWarningViewController.h"

@implementation HRPasscodeWarningViewController

@synthesize imageView;
@synthesize confirmButton;

- (void)dealloc {
    [imageView release];
    [confirmButton release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.confirmButton.hidden = YES;
    
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
    [self dismissModalViewControllerAnimated:YES];
}

@end
