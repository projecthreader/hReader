//
//  SVViewController.m
//
//  Created by Caleb Davenport on 4/16/12.
//  Copyright (c) 2012 The MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SVPanelViewController.h"

#import "UIViewController+SVPanelViewControllerAdditions.h"

#define kAccessoryViewWidth 335.0

@interface SVPanelViewController () {
    UIView * __strong mask;
    NSInteger state;
}

/*
 
 Configures state so that the main view can transition out to expose an
 accessory view. This adds a mask view, shadow, and gesture handler to the main
 view.
 
 */
- (void)prepareMainViewForTransition;

/*
 
 Resets the view layout to the default with both accessory views hidden.
 
 */
- (void)configureSubviews;

/*
 
 Gets the accessory controller that is currently visible based on the state.
 
 */
- (UIViewController *)visibleAccessoryViewController;

@end

@implementation SVPanelViewController

@synthesize mainViewController = _mainViewController;
@synthesize leftAccessoryViewController = _leftViewController;
@synthesize rightAccessoryViewController = _rightViewController;

#pragma mark - property overrides

- (void)setMainViewController:(UIViewController *)controller {
    [_mainViewController removeFromParentViewController];
    if ([_mainViewController isViewLoaded]) {
        [_mainViewController viewWillDisappear:NO];
        [_mainViewController.view removeFromSuperview];
        [_mainViewController viewDidDisappear:NO];
    }
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
    _mainViewController = controller;
    if ([self isViewLoaded]) {
        [self.view addSubview:_mainViewController.view];
    }
    [self configureSubviews];
}

- (void)setLeftAccessoryViewController:(UIViewController *)controller {
    [_leftViewController removeFromParentViewController];
    if ([_leftViewController isViewLoaded]) {
        if (state < 0) {
            [_leftViewController viewWillDisappear:NO];
        }
        [_leftViewController.view removeFromSuperview];
        if (state < 0) {
            [_leftViewController viewDidDisappear:NO];
        }
        state = 0;
    }
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
    _leftViewController = controller;
    if ([self isViewLoaded]) {
        [self.view addSubview:_leftViewController.view];
    }
    [self configureSubviews];
}

- (void)setRightAccessoryViewController:(UIViewController *)controller {
    [_rightViewController removeFromParentViewController];
    if ([_rightViewController isViewLoaded]) {
        if (state > 0) {
            [_rightViewController viewWillDisappear:NO];
        }
        [_rightViewController.view removeFromSuperview];
        if (state > 0) {
            [_rightViewController viewDidDisappear:NO];
        }
        state = 0;
    }
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
    _rightViewController = controller;
    if ([self isViewLoaded]) {
        [self.view addSubview:_rightViewController.view];
    }
    [self configureSubviews];
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:(121.0 / 255.0)
                                                green:(127.0 / 255.0)
                                                 blue:(144.0 / 255.0)
                                                alpha:1.0];
    if (self.leftAccessoryViewController) {
        [self.view addSubview:self.leftAccessoryViewController.view];
    }
    if (self.rightAccessoryViewController) {
        [self.view addSubview:self.rightAccessoryViewController.view];
    }
    if (self.mainViewController) {
        [self.view addSubview:self.mainViewController.view];
    }
    [self configureSubviews];
}

- (void)viewDidUnload {
    [self.childViewControllers setNilValueForKey:@"view"];
    [self.childViewControllers makeObjectsPerformSelector:@selector(viewDidUnload)];
    mask = nil;
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.mainViewController viewWillDisappear:animated];
    [self.visibleAccessoryViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.mainViewController viewDidDisappear:animated];
    [self.visibleAccessoryViewController viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.mainViewController viewWillAppear:animated];
    [self.visibleAccessoryViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.mainViewController viewDidAppear:animated];
    [self.visibleAccessoryViewController viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return UIInterfaceOrientationIsLandscape(orientation);
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers {
    return NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:orientation duration:duration];
    [self.mainViewController willRotateToInterfaceOrientation:orientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:orientation duration:duration];
    [self.mainViewController willAnimateRotationToInterfaceOrientation:orientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation {
    [super didRotateFromInterfaceOrientation:orientation];
    [self.mainViewController didRotateFromInterfaceOrientation:orientation];
}

#pragma mark - object methods

- (void)prepareMainViewForTransition {
    
    // get view
    UIView *view = self.mainViewController.view;
    
    // shadow
    CALayer *layer = view.layer;
    layer.shouldRasterize = YES;
    layer.rasterizationScale = [[UIScreen mainScreen] scale];
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOpacity = 0.25;
    layer.shadowOffset = CGSizeMake(0.0, 0.0);
    layer.shadowRadius = 10.0;
    
    // gesture
    mask = [[UIView alloc] initWithFrame:view.bounds];
    mask.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(maskViewDidReceiveTap:)];
    [mask addGestureRecognizer:tap];
    [view addSubview:mask];
    
}

- (void)configureSubviews {
    
    // reset view ordering
    [self.view bringSubviewToFront:self.mainViewController.view];
    if (state != 0) {
        self.mainViewController.view.layer.shouldRasterize = NO;
    }
    
    // vars
    UIViewController *controller = [self visibleAccessoryViewController];
    UIView *view = nil;
    CGRect bounds = self.view.bounds;
    state = 0;
    
    // start transition
    [controller viewWillDisappear:NO];
    
    // left view
    view = self.leftAccessoryViewController.view;
    if (view) {
        view.frame = CGRectMake(0.0, 0.0, kAccessoryViewWidth, bounds.size.height);
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    
    // right view
    view = self.rightAccessoryViewController.view;
    if (view) {
        view.frame = CGRectMake(bounds.size.width - kAccessoryViewWidth, 0.0, kAccessoryViewWidth, bounds.size.height);
        view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin);
    }
    
    // main view
    view = self.mainViewController.view;
    view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    view.frame = bounds;
    
    // finish transition
    [controller viewDidDisappear:NO];
    
}

- (UIViewController *)visibleAccessoryViewController {
    if (state < 0) {
        return self.leftAccessoryViewController;
    }
    else if (state > 0) {
        return self.rightAccessoryViewController;
    }
    else {
        return nil;
    }
}

- (void)exposeLeftAccessoryViewController:(BOOL)animated {
    NSAssert(self.leftAccessoryViewController, @"There is no left view controller");
    [self prepareMainViewForTransition];
    state = -1;
    CGRect rect = CGRectOffset(self.view.bounds,
                               (self.rightAccessoryViewController.view.bounds.size.width + 1.0),
                               0.0);
    if (animated) {
        [self.leftAccessoryViewController viewWillAppear:animated];
        [UIView
         animateWithDuration:UINavigationControllerHideShowBarDuration
         delay:0.0
         options:UIViewAnimationCurveEaseInOut
         animations:^{
             self.mainViewController.view.frame = rect;
         }
         completion:^(BOOL finished) {
             [self.leftAccessoryViewController viewDidAppear:animated];
         }];
    }
    else {
        [self.leftAccessoryViewController viewWillAppear:animated];
        self.mainViewController.view.frame = rect;
        [self.leftAccessoryViewController viewDidAppear:animated];
    }
}

- (void)exposeRightAccessoryViewController:(BOOL)animated {
    NSAssert(self.rightAccessoryViewController, @"There is no right view controller");
    [self prepareMainViewForTransition];
    state = 1;
    CGRect rect = CGRectOffset(self.view.bounds,
                               (self.rightAccessoryViewController.view.bounds.size.width + 1.0) * -1.0,
                               0.0);
    if (animated) {
        [self.rightAccessoryViewController viewWillAppear:animated];
        [UIView
         animateWithDuration:UINavigationControllerHideShowBarDuration
         delay:0.0
         options:UIViewAnimationCurveEaseInOut
         animations:^{
             self.mainViewController.view.frame = rect;
         }
         completion:^(BOOL finished) {
             [self.rightAccessoryViewController viewDidAppear:animated];
         }];
    }
    else {
        [self.rightAccessoryViewController viewWillAppear:animated];
        self.mainViewController.view.frame = rect;
        [self.rightAccessoryViewController viewDidAppear:animated];
    }
}

- (void)hideAccessoryViewControllers:(BOOL)animated {
    if (animated) {
        UIViewController *controller = [self visibleAccessoryViewController];
        [controller viewWillDisappear:animated];
        state = 0;
        [UIView
         animateWithDuration:UINavigationControllerHideShowBarDuration
         delay:0.0
         options:UIViewAnimationCurveEaseInOut
         animations:^{
             [self configureSubviews];
         }
         completion:^(BOOL finished) {
             [mask removeFromSuperview];
             mask = nil;
             [controller viewDidDisappear:animated];
             self.mainViewController.view.layer.shouldRasterize = NO;
         }];
    }
    else {
        [self configureSubviews];
        [mask removeFromSuperview];
        mask = nil;
    }
}

#pragma mark - gestures

- (void)maskViewDidReceiveTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        [self hideAccessoryViewControllers:YES];
    }
}

@end
