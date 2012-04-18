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

@interface SVPanelViewController () {
@private
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

@synthesize mainViewController = __mainViewController;
@synthesize leftAccessoryViewController = __leftViewController;
@synthesize rightAccessoryViewController = __rightViewController;

#pragma mark - property overrides

- (void)setMainViewController:(UIViewController *)controller {
    [__mainViewController removeFromParentViewController];
    if ([__mainViewController isViewLoaded]) {
        [__mainViewController viewWillDisappear:NO];
        [__mainViewController.view removeFromSuperview];
        [__mainViewController viewDidDisappear:NO];
    }
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
    __mainViewController = controller;
    if ([self isViewLoaded]) {
        [self.view addSubview:__mainViewController.view];
    }
    [self configureSubviews];
}

- (void)setLeftAccessoryViewController:(UIViewController *)controller {
    [__leftViewController removeFromParentViewController];
    if ([__leftViewController isViewLoaded]) {
        if (state < 0) {
            [__leftViewController viewWillDisappear:NO];
        }
        [__leftViewController.view removeFromSuperview];
        if (state < 0) {
            [__leftViewController viewDidDisappear:NO];
        }
        state = 0;
    }
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
    __leftViewController = controller;
    if ([self isViewLoaded]) {
        [self.view addSubview:__leftViewController.view];
    }
    [self configureSubviews];
}

- (void)setRightAccessoryViewController:(UIViewController *)controller {
    [__rightViewController removeFromParentViewController];
    if ([__rightViewController isViewLoaded]) {
        if (state > 0) {
            [__rightViewController viewWillDisappear:NO];
        }
        [__rightViewController.view removeFromSuperview];
        if (state > 0) {
            [__rightViewController viewDidDisappear:NO];
        }
        state = 0;
    }
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
    __rightViewController = controller;
    if ([self isViewLoaded]) {
        [self.view addSubview:__rightViewController.view];
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
    return [self.mainViewController shouldAutorotateToInterfaceOrientation:orientation];
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
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOpacity = 0.25;
    layer.shadowOffset = CGSizeMake(0.0, 0.0);
    layer.shadowRadius = 10.0;
    
    // gesture
    UIView *mask = [[UIView alloc] initWithFrame:view.bounds];
    mask.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(hideAccessoryViewControllers:)];
    [mask addGestureRecognizer:tap];
    [view addSubview:mask];
    
}

- (void)configureSubviews {
    
    // reset view ordering
    [self.view bringSubviewToFront:self.mainViewController.view];
    
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

#pragma mark - gestures

- (void)hideAccessoryViewControllers:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        UIViewController *controller = [self visibleAccessoryViewController];
        
        [controller viewWillDisappear:YES];
        [UIView
         animateWithDuration:UINavigationControllerHideShowBarDuration
         delay:0.0
         options:UIViewAnimationCurveEaseInOut
         animations:^{
             [self configureSubviews];
         }
         completion:^(BOOL finished) {
             [controller viewDidDisappear:YES];
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
