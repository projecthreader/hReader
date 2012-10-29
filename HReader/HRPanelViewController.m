//
//  HRPanelViewController.m
//  HReader
//
//  Created by Caleb Davenport on 10/11/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRPanelViewController.h"

@implementation HRPanelViewController {
    UIView *_mask;
    short _state;
}

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
    [_leftAccessoryViewController removeFromParentViewController];
    if ([_leftAccessoryViewController isViewLoaded]) {
        if (_state < 0) {
            [_leftAccessoryViewController viewWillDisappear:NO];
        }
        [_leftAccessoryViewController.view removeFromSuperview];
        if (_state < 0) {
            [_leftAccessoryViewController viewDidDisappear:NO];
        }
    }
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
    _leftAccessoryViewController = controller;
    if ([self isViewLoaded]) {
        [self.view addSubview:_leftAccessoryViewController.view];
    }
    [self configureSubviews];
}

- (void)setRightAccessoryViewController:(UIViewController *)controller {
    [_rightAccessoryViewController removeFromParentViewController];
    if ([_rightAccessoryViewController isViewLoaded]) {
        if (_state > 0) {
            [_rightAccessoryViewController viewWillDisappear:NO];
        }
        [_rightAccessoryViewController.view removeFromSuperview];
        if (_state > 0) {
            [_rightAccessoryViewController viewDidDisappear:NO];
        }
    }
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
    _rightAccessoryViewController = controller;
    if ([self isViewLoaded]) {
        [self.view addSubview:_rightAccessoryViewController.view];
    }
    [self configureSubviews];
}

#pragma mark - gesture handlers

- (void)maskViewDidReceiveTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        [self showMainViewController:YES];
    }
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

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers {
    return NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.mainViewController viewWillDisappear:animated];
    [[self visibleAccessoryViewController] viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.mainViewController viewDidDisappear:animated];
    [[self visibleAccessoryViewController] viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.mainViewController viewWillAppear:animated];
    [[self visibleAccessoryViewController] viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.mainViewController viewDidAppear:animated];
    [[self visibleAccessoryViewController] viewDidAppear:animated];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:orientation duration:duration];
    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj willRotateToInterfaceOrientation:orientation duration:duration];
    }];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:orientation duration:duration];
    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj willAnimateRotationToInterfaceOrientation:orientation duration:duration];
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation {
    [super didRotateFromInterfaceOrientation:orientation];
    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj didRotateFromInterfaceOrientation:orientation];
    }];
}

#pragma mark - view layout methods

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
    if (_mask == nil) {
        _mask = [[UIView alloc] initWithFrame:view.bounds];
        _mask.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(maskViewDidReceiveTap:)];
        [_mask addGestureRecognizer:tap];
        [view addSubview:_mask];
    }
    
}

- (void)configureSubviews {
    
    // reset view ordering
    [self.view bringSubviewToFront:self.mainViewController.view];
    if (_state != 0) {
        self.mainViewController.view.layer.shouldRasterize = NO;
    }
    
    // vars
    UIViewController *controller = [self visibleAccessoryViewController];
    UIView *view = nil;
    CGRect bounds = self.view.bounds;
    _state = 0;
    
    // start transition
    [controller viewWillDisappear:NO];
    
    // left view
    view = self.leftAccessoryViewController.view;
    if (view) {
        view.frame = CGRectMake(0.0, 0.0, self.leftAccessoryViewWidth, bounds.size.height);
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    
    // right view
    view = self.rightAccessoryViewController.view;
    if (view) {
        view.frame = CGRectMake(bounds.size.width - self.rightAccessoryViewWidth,
                                0.0,
                                self.rightAccessoryViewWidth,
                                bounds.size.height);
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
    if (_state < 0) { return self.leftAccessoryViewController; }
    else if (_state > 0) { return self.rightAccessoryViewController; }
    else { return nil; }
}

- (void)showLeftAccessoryViewController:(BOOL)animated {
    NSAssert(self.leftAccessoryViewController, @"There is no left view controller");
    [self prepareMainViewForTransition];
    _state = -1;
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

- (void)showRightAccessoryViewController:(BOOL)animated {
    NSAssert(self.rightAccessoryViewController, @"There is no right view controller");
    [self prepareMainViewForTransition];
    _state = 1;
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

- (void)showMainViewController:(BOOL)animated {
    if (animated) {
        UIViewController *controller = [self visibleAccessoryViewController];
        [controller viewWillDisappear:animated];
        _state = 0;
        [UIView
         animateWithDuration:UINavigationControllerHideShowBarDuration
         delay:0.0
         options:UIViewAnimationCurveEaseInOut
         animations:^{
             [self configureSubviews];
         }
         completion:^(BOOL finished) {
             [_mask removeFromSuperview];
             _mask = nil;
             [controller viewDidDisappear:animated];
             self.mainViewController.view.layer.shouldRasterize = NO;
         }];
    }
    else {
        [self configureSubviews];
        [_mask removeFromSuperview];
        _mask = nil;
    }
}

@end

@implementation UIViewController (HRPanelViewControllerAdditions)

+ (HRPanelViewController *)panelViewControllerContainingViewController:(UIViewController *)controller {
    if (controller == nil) {
        return nil;
    }
    else if ([controller isKindOfClass:[HRPanelViewController class]]) {
        return (id)controller;
    }
    else {
        return [self panelViewControllerContainingViewController:controller.parentViewController];
    }
}

- (HRPanelViewController *)panelViewController {
    return [UIViewController panelViewControllerContainingViewController:self];
}

@end
