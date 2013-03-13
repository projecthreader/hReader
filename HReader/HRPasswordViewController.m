//
//  HRPasswordViewController.m
//  HReader
//
//  Created by Caleb Davenport on 12/27/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRPasswordViewController.h"

#import <SecurityCheck/debugCheck.h>

@interface HRPasswordViewController()

//-----------------------------------
// Callback block from securityCheck
//-----------------------------------
typedef void (^cbBlock) (void);

- (void) weHaveAProblem;

@end

@interface HRPasswordViewController ()

@property (nonatomic, weak) IBOutlet UIView *passwordFieldContainerView;
@property (nonatomic, weak) IBOutlet UIView *passwordFieldDividerView;

@end

@implementation HRPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CALayer *layer = self.passwordFieldContainerView.layer;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOffset = CGSizeMake(0.0, 0.0);
    layer.shadowOpacity = 0.1;
    layer.shadowRadius = 5.0;
    layer.borderColor = [[UIColor colorWithWhite:0.79 alpha:1.0] CGColor];
    layer.borderWidth = 1.0;
    layer.cornerRadius = 10.0;
    layer = self.passwordFieldDividerView.layer;
    layer.shadowColor = [[UIColor whiteColor] CGColor];
    layer.shadowOffset = CGSizeMake(0.0, 1.0);
    layer.shadowOpacity = 0.5;
    layer.shadowRadius = 0.0;

#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
    
    //--------------------------------------------------------------------------
    // check for the presence of a debugger, call weHaveAProblem if there is one
    //--------------------------------------------------------------------------
    cbBlock dbChkCallback = ^{
        
        __weak id weakSelf = self;
        
        if (weakSelf) [weakSelf weHaveAProblem];
        
    };
    
    dbgCheck(dbChkCallback);
    
#endif

}

//--------------------------------------------------------------------
// if a debugger is attched to the app then this method will be called
//--------------------------------------------------------------------
- (void) weHaveAProblem {
    
    exit(0);
}

@end
