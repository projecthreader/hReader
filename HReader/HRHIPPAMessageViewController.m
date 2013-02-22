//
//  HRHIPPAMessageViewController.m
//  HReader
//
//  Created by Caleb Davenport on 7/5/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRHIPPAMessageViewController.h"
#import <SecurityCheck/debugCheck.h>

static NSString * const HRHIPPAMessageAcceptedKey = @"HRHIPPAMessageAccepted";

@interface HRHIPPAMessageViewController() {
    
    //--------------------------------
    // debugCheck timer
    //--------------------------------
    dispatch_queue_t  _queue;
    dispatch_source_t _timer;
    
}
//--------------------------------
// Callback block from debugCheck
//--------------------------------
typedef void (^cbBlock) (void);

- (void) weHaveAProblem;

@end

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
    
    //--------------------------------------------------------------------------
    // check for the presence of a debugger, call weHaveAProblem if there is one
    //--------------------------------------------------------------------------
    cbBlock dbChkCallback = ^{
        
        __weak id weakSelf = self;
        
        if (weakSelf) [weakSelf weHaveAProblem];
        
    };
    
    _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,_queue);
    
    dispatch_source_set_timer(_timer
                              ,dispatch_time(DISPATCH_TIME_NOW, 0)
                              ,1.0 * NSEC_PER_SEC
                              ,0.0 * NSEC_PER_SEC);
    
    dispatch_source_set_event_handler(_timer, ^{ dbgCheck(dbChkCallback); } );
    
    dispatch_resume(_timer);
    
    //-----------------------------------------------------------------------------
    
}

//--------------------------------------------------------------------
// if a debugger is attched to the app then this method will be called
//--------------------------------------------------------------------
- (void) weHaveAProblem {
    
    dispatch_source_cancel(_timer);
    
    exit(0);
}
- (void)invalidate {
    
    dispatch_source_cancel(_timer);
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
