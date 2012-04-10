//
//  HRRootViewController.m
//  HReader
//
//  Created by Marshall Huss on 11/30/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRRootViewController.h"
#import "HRPatientSummaryViewController.h"
#import "HRTimelineViewController.h"
#import "HRMessagesViewController.h"
#import "HRDoctorsViewController.h"
#import "HRC32ViewController.h"
#import "HRPasscodeWarningViewController.h"
#import "HRPasscodeManager.h"
#import "GCActionSheet.h"

static int HRRootViewControllerTitleContext;

@interface HRRootViewController () {
    GCActionSheet *__actionSheet;
}

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIViewController *visibleViewController;
@property (nonatomic, strong) UILabel *lastUpdatedLabel;

@end

@implementation HRRootViewController

@synthesize visibleViewController   = __visibleViewController;
@synthesize segmentedControl        = __segmentedControl;
@synthesize lastUpdatedLabel        = __lastUpdatedLabel;

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
        controller = [[HRTimelineViewController alloc] initWithNibName:nil bundle:nil];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeObserver:self forKeyPath:@"title"];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [__actionSheet dismissWithClickedButtonIndex:__actionSheet.cancelButtonIndex animated:NO];
    [TestFlight passCheckpoint:segue.identifier];
}

- (void)setVisibleViewController:(UIViewController *)controller {

    controller.view.frame = self.view.bounds;
    controller.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self
     transitionFromViewController:__visibleViewController
     toViewController:controller
     duration:0.0
     options:0
     animations:^{}
     completion:^(BOOL finished) {
         __visibleViewController = controller;
         self.title = __visibleViewController.title;
         [TestFlight passCheckpoint:[NSString stringWithFormat:@"Navigation - %@", __visibleViewController.title]];
         [__visibleViewController didMoveToParentViewController:self];
     }];

}

#pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &HRRootViewControllerTitleContext) {
        UIViewController *controller = (id)object;
        NSUInteger index = [self.childViewControllers indexOfObject:controller];
        [self.segmentedControl setTitle:controller.title forSegmentAtIndex:index];
        if (controller == self.visibleViewController) {
            self.title = controller.title;
        }
    }
}

#pragma mark - view methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // configure toolbar
    {
//        UIBarButtonItem *flexible = [[UIBarButtonItem alloc]
//                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
//                                      target:nil
//                                      action:nil];
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 0.0, 800.0, 30.0)];
//        label.textAlignment = UITextAlignmentCenter;
//        label.shadowColor = [UIColor whiteColor];
//        label.shadowOffset = CGSizeMake(0.0, 1.0);
//        label.font = [UIFont boldSystemFontOfSize:14.0];
//        label.textColor = [UIColor
//                           colorWithRed:(107.0 / 255.0)
//                           green:(115.0 / 255.0)
//                           blue:(126.0 / 255.0)
//                           alpha:1.0];
//        label.backgroundColor = [UIColor clearColor];
//        UIBarButtonItem *labelItem = [[UIBarButtonItem alloc] initWithCustomView:label];
//        self.toolbarItems = [NSArray arrayWithObjects:flexible, self.toolsBarButtonItem, self.aboutBarButtonItem, nil];
//        self.lastUpdatedLabel = label;
    }
    
//    self.navigationController.toolbarHidden = YES;
    
    // configure logo
    {
        UIImage *logo = [UIImage imageNamed:@"Logo"];
        UIImageView *logoView = [[UIImageView alloc] initWithImage:logo];
        logoView.frame = CGRectMake(5, 5, 150, 34);
        UIBarButtonItem *logoItem = [[UIBarButtonItem alloc] initWithCustomView:logoView];
        self.navigationItem.leftBarButtonItem = logoItem;
    }
    
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
        [control addTarget:self action:@selector(segmentSelected) forControlEvents:UIControlEventValueChanged];  
        [control addTarget:self action:@selector(hideToolbarSheet) forControlEvents:UIControlEventValueChanged];
        self.navigationItem.titleView = control;
        self.segmentedControl = control;
    }
    
    // add bar button items to right
    /*
    {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.aboutBarButtonItem, self.toolsBarButtonItem, nil];
    }
     */
    
    // configure first view
    {
        id controller = [self.childViewControllers objectAtIndex:0];
        __visibleViewController = controller;
        [controller view].frame = self.view.bounds;
        [controller view].autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [self.view addSubview:[controller view]];
        [controller didMoveToParentViewController:self];
    }
    
    // set last updated text
//    self.lastUpdatedLabel.text = @"Last Updated: 05 May by Joseph Yang, M.D. (Columbia Pediatric Associates)";
    
}
- (void)viewDidUnload {
    self.lastUpdatedLabel = nil;
    self.segmentedControl = nil;
    self.visibleViewController = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return UIInterfaceOrientationIsLandscape(orientation);
}

#pragma mark - button actions

- (void)segmentSelected {
    NSInteger index = self.segmentedControl.selectedSegmentIndex;
    self.visibleViewController = [self.childViewControllers objectAtIndex:index];
}

//- (IBAction)toolsButtonPressed:(id)sender {
//    if (__actionSheet == nil) {
//        __actionSheet = [[GCActionSheet alloc] initWithTitle:@"Tools"];
//        id __weak weakSelf = self;
//        [__actionSheet addButtonWithTitle:@"C32 HTML" block:^{
//            id __strong strongSelf = weakSelf;
//            [strongSelf performSegueWithIdentifier:@"C32HTMLSegue" sender:strongSelf];
//        }];
//        [__actionSheet setDidDismissBlock:^{
//            HRRootViewController * __strong strongSelf = weakSelf;
//            strongSelf->__actionSheet = nil;
//        }];
//        [__actionSheet showFromBarButtonItem:sender animated:YES];
//    }
//}

- (void)hideToolbarSheet {
    [__actionSheet dismissWithClickedButtonIndex:__actionSheet.cancelButtonIndex animated:NO];
}
     
@end
