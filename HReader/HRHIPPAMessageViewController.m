//
//  HRHIPPAMessageViewController.m
//  HReader
//
//  Created by Caleb Davenport on 7/5/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRHIPPAMessageViewController.h"

static NSString * const HRHIPPAMessageAcceptedKey = @"HRHIPPAMessageAccepted";

@implementation HRHIPPAMessageViewController

+ (void)initialize {
    if (self == [HRHIPPAMessageViewController class]) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:
         [NSDictionary
          dictionaryWithObject:[NSNumber numberWithBool:NO]
          forKey:HRHIPPAMessageAcceptedKey]];
    }
}

+ (BOOL)hasAcceptedHIPPAMessage {
    return [[NSUserDefaults standardUserDefaults] boolForKey:HRHIPPAMessageAcceptedKey];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"hippa" withExtension:@"txt"];
    self.textView.text = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:nil];
    UIImage *normal = [[UIImage imageNamed:@"GradientButton"] stretchableImageWithLeftCapWidth:11.0 topCapHeight:0.0];
    UIImage *highlighted = [[UIImage imageNamed:@"GradientButtonHighlighted"] stretchableImageWithLeftCapWidth:11.0 topCapHeight:0.0];
    [self.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setBackgroundImage:normal forState:UIControlStateNormal];
        [obj setBackgroundImage:highlighted forState:UIControlStateHighlighted];
    }];
    CALayer *layer = [[[self.buttons objectAtIndex:0] superview] layer];
    layer.shadowOffset = CGSizeMake(0.0, 0.0);
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowRadius = 10.0;
    layer.shadowOpacity = 0.25;
    layer.borderColor = [[UIColor colorWithWhite:0.79 alpha:1.0] CGColor];
    layer.borderWidth = 1.0;
    layer.shouldRasterize = YES;
    layer.rasterizationScale = [[UIScreen mainScreen] scale];
}

- (IBAction)acceptButtonPressed:(id)sender {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:YES forKey:HRHIPPAMessageAcceptedKey];
    [settings synchronize];
    if (self.target && self.action) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.action];
#pragma clang diagnostic pop
    }
}

- (IBAction)doNotWant:(id)sender {
    [[[UIAlertView alloc]
      initWithTitle:@"HIPPA Notice"
      message:@"You must accept the HIPPA notice in order to use hReader.\n\nIf you do not accept, please quit and uninstall the application."
      delegate:nil
      cancelButtonTitle:@"OK"
      otherButtonTitles:nil]
     show];
}

@end
