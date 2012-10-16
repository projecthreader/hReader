//
//  HRTabBarController.m
//  HReader
//
//  Created by Caleb Davenport on 10/11/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRTabBarController.h"
#import "HRMessagesViewController.h"
#import "HRAppletConfigurationViewController.h"
#import "HRPeoplePickerViewController.h"
#import "HRPanelViewController.h"

static int HRRootViewControllerTitleContext = 0;

@implementation HRTabBarController {
    UISegmentedControl *_segmentedControl;
    UIViewController *_visibleViewController;
}

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        
        // vars
        id controller;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
        
        // create child view controllers
        controller = [storyboard instantiateViewControllerWithIdentifier:@"SummaryViewController"];
        [self addChildViewController:controller];
        controller = [storyboard instantiateViewControllerWithIdentifier:@"TimelineViewController"];
        [self addChildViewController:controller];
        controller = [[HRMessagesViewController alloc] initWithNibName:nil bundle:nil];
        [self addChildViewController:controller];
        controller = [storyboard instantiateViewControllerWithIdentifier:@"DoctorsViewController"];
        [self addChildViewController:controller];
        
        // register observers
        [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSAssert([obj title], @"Child view controllers must have a title");
            [obj
             addObserver:self
             forKeyPath:@"title"
             options:NSKeyValueObservingOptionNew
             context:&HRRootViewControllerTitleContext];
        }];
        
    }
    return self;
}

- (void)dealloc {
    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj
         removeObserver:self
         forKeyPath:@"title"
         context:&HRRootViewControllerTitleContext];
    }];
}

- (void)setVisibleViewController:(UIViewController *)controller {
    
    // declare completion block
    void (^completion) (BOOL) = ^(BOOL finished) {
        _visibleViewController = controller;
        self.title = _visibleViewController.title;
        [_visibleViewController didMoveToParentViewController:self];
    };
    
    // setup target controller's view
    controller.view.frame = self.view.bounds;
    controller.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    // transition
    if (_visibleViewController) {
        [self
         transitionFromViewController:_visibleViewController
         toViewController:controller
         duration:0.0
         options:0
         animations:^{}
         completion:completion];
    }
    else {
        [self.view addSubview:controller.view];
        completion(YES);
    }

}

#pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &HRRootViewControllerTitleContext) {
        UIViewController *controller = (id)object;
        NSUInteger index = [self.childViewControllers indexOfObject:controller];
        [_segmentedControl setTitle:controller.title forSegmentAtIndex:index];
        if (controller == _visibleViewController) {
            self.title = controller.title;
        }
    }
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // configure segmented control
    {
        NSArray *titles = [self.childViewControllers valueForKey:@"title"];
        UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:titles];
        control.segmentedControlStyle = UISegmentedControlStyleBar;
        control.selectedSegmentIndex = 0;
        NSUInteger count = [titles count];
        for (NSUInteger i = 0; i < count; i++) {
            [control setWidth:(600.0 / count) forSegmentAtIndex:i];
        }
        [control addTarget:self action:@selector(segmentedControlValueChanged) forControlEvents:UIControlEventValueChanged];
        self.navigationItem.titleView = control;
        _segmentedControl = control;
    }
    
    // configure first view
    {
        UIViewController *controller = [self.childViewControllers objectAtIndex:0];
        [self setVisibleViewController:controller];
    }
    
}

- (void)viewDidUnload {
    _segmentedControl = nil;
    _visibleViewController = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return UIInterfaceOrientationIsLandscape(orientation);
}

#pragma mark - button events

- (void)segmentedControlValueChanged {
    NSInteger index = _segmentedControl.selectedSegmentIndex;
    UIViewController *controller = [self.childViewControllers objectAtIndex:index];
    [self setVisibleViewController:controller];
}

- (IBAction)applets:(id)sender {
    [self.panelViewController showRightAccessoryViewController:YES];
}

- (IBAction)people:(id)sender {
    [self.panelViewController showLeftAccessoryViewController:YES];
}

@end
