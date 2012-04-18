//
//  SVViewController.m
//  SlidyView
//
//  Created by Caleb Davenport on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SVPanelViewController.h"

#import "UIViewController+SVPanelViewControllerAdditions.h"

#define kAccessoryViewWidth 335.0

@interface SVPanelViewController ()

- (void)showViewShadow;

- (void)addMaskView;

@end

@implementation SVPanelViewController

@synthesize mainViewController = __mainViewController;
@synthesize leftAccessoryViewController = __leftViewController;
@synthesize rightAccessoryViewController = __rightViewController;

#pragma mark - property overrides

- (void)setMainViewController:(UIViewController *)controller {
    [__mainViewController removeFromParentViewController];
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
    __mainViewController = controller;
}

- (void)setLeftAccessoryViewController:(UIViewController *)controller {
    [__leftViewController removeFromParentViewController];
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
    __leftViewController = controller;
}

- (void)setRightAccessoryViewController:(UIViewController *)controller {
    [__rightViewController removeFromParentViewController];
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
    __rightViewController = controller;
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // self
    self.view.backgroundColor = [UIColor colorWithRed:(121.0 / 255.0)
                                                green:(127.0 / 255.0)
                                                 blue:(144.0 / 255.0)
                                                alpha:1.0];
    
    // vars
    UIView *view;
    CGRect bounds = self.view.bounds;
    
    // left view
    view = self.leftAccessoryViewController.view;
    if (view) {
        view.frame = CGRectMake(0.0, 0.0, kAccessoryViewWidth, bounds.size.height);
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:view];
    }
    
    // right view
    view = self.rightAccessoryViewController.view;
    if (view) {
        view.frame = CGRectMake(bounds.size.width - kAccessoryViewWidth, 0.0, kAccessoryViewWidth, bounds.size.height);
        view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin);
        [self.view addSubview:view];
    }
    
    // main view
    view = self.mainViewController.view;
    view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    view.frame = bounds;
    [self.view addSubview:view];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return [self.mainViewController shouldAutorotateToInterfaceOrientation:orientation];
}

#pragma mark - object methods

- (void)showViewShadow {
    CALayer *layer = self.mainViewController.view.layer;
    layer.shouldRasterize = YES;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOpacity = 0.25;
    layer.shadowOffset = CGSizeMake(0.0, 0.0);
    layer.shadowRadius = 10.0;
}

- (void)addMaskView {
    UIView *view = self.mainViewController.view;
    UIView *mask = [[UIView alloc] initWithFrame:view.bounds];
    mask.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(hideAccessoryViewControllers:)];
    [mask addGestureRecognizer:tap];
    [view addSubview:mask];
}

- (void)exposeLeftAccessoryViewController:(BOOL)animated {
    NSAssert(self.leftAccessoryViewController, @"There is no left view controller");
    [self showViewShadow];
    CGRect rect = CGRectOffset(self.view.bounds,
                               (self.rightAccessoryViewController.view.bounds.size.width + 1.0),
                               0.0);
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:UINavigationControllerHideShowBarDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    }
    self.mainViewController.view.frame = rect;
    if (animated) {
        [UIView commitAnimations];
    }
    [self addMaskView];
}

- (void)exposeRightAccessoryViewController:(BOOL)animated {
    NSAssert(self.rightAccessoryViewController, @"There is no right view controller");
    [self showViewShadow];
    CGRect rect = CGRectOffset(self.view.bounds,
                               (self.rightAccessoryViewController.view.bounds.size.width + 1.0) * -1.0,
                               0.0);
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:UINavigationControllerHideShowBarDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    }
    self.mainViewController.view.frame = rect;
    if (animated) {
        [UIView commitAnimations];
    }
    [self addMaskView];
}

#pragma mark - gestures

- (void)hideAccessoryViewControllers:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        [UIView
         animateWithDuration:UINavigationControllerHideShowBarDuration
         delay:0.0
         options:UIViewAnimationCurveEaseInOut
         animations:^{
             self.mainViewController.view.frame = self.view.bounds;
         }
         completion:^(BOOL finished) {
             CALayer *layer = self.mainViewController.view.layer;
             layer.shouldRasterize = NO;
             layer.shadowColor = [[UIColor blackColor] CGColor];
             layer.shadowOpacity = 0.0;
             layer.shadowOffset = CGSizeMake(0.0, 0.0);
             layer.shadowRadius = 0.0;
             [gesture.view removeFromSuperview];
         }];
    }
}

@end
