//
//  HRPatientSummarySplitViewController.m
//  HReader
//
//  Created by Marshall Huss on 11/30/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRPatientSummaryViewController.h"
#import "HRPatientSwipeViewController.h"
#import "HRRootViewController.h"
#import "HRPatient.h"

@interface HRPatientSummaryViewController ()
- (void)toggleViewShadow:(BOOL)on;
@end

@implementation HRPatientSummaryViewController

@synthesize patientHeaderView           = __patientHeaderView;
@synthesize patientScrollView           = __patientScrollView;
@synthesize patientSummaryView          = __patientSummaryView;
@synthesize patientSwipeViewContoller   = __patientSwipeViewController;

@synthesize patientName                 = __patientName;


- (void)dealloc {
    [__patientSummaryView release];
    [__patientScrollView release];
    [__patientSummaryView release];
    [__patientHeaderView release];
    [__patientSwipeViewController release];
    
    [__patientName release];
    
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
    
    self.patientSwipeViewContoller = [[[HRPatientSwipeViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    self.patientSwipeViewContoller.patientsArray = [HRConfig patients];
    self.patientSwipeViewContoller.view.frame = CGRectMake(32, 15, 175, 175);
    [self.patientHeaderView addSubview:self.patientSwipeViewContoller.view];
    
    
    // Header shadow
    CALayer *layer = self.patientHeaderView.layer;
    layer.shadowColor = [[UIColor clearColor] CGColor];
    layer.shadowOpacity = 0.5;
    layer.shadowOffset = CGSizeMake(0, 3);
    layer.masksToBounds = NO;
    [self.view bringSubviewToFront:self.patientHeaderView];   
    
    // Set scrollview content size and add patient summary view
    self.patientScrollView.contentSize = self.patientSummaryView.frame.size;
    [self.patientScrollView addSubview:self.patientSummaryView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(patientChanged:) name:HRPatientDidChangeNotification object:nil];
    
}

- (void)viewDidUnload {
    self.patientSummaryView = nil;
    self.patientScrollView = nil;
    self.patientSummaryView = nil;
    self.patientHeaderView = nil;
    self.patientSwipeViewContoller = nil;
    
    self.patientName = nil;
    
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    self.patientSwipeViewContoller.delegate = (HRRootViewController *)self.parentViewController;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > 0) {
        [self toggleViewShadow:YES];
    } else {
        [self toggleViewShadow:NO];
    }
}

#pragma mark - NSNotificationCenter

- (void)patientChanged:(NSNotification *)notif {
    HRPatient *patient = [notif.userInfo objectForKey:@"patient"];
    NSLog(@"Name: %@", patient.name);
    self.patientName.text = [patient.name uppercaseString];
}


#pragma mark - Private methods

- (void)toggleViewShadow:(BOOL)on {
    CALayer *layer = self.patientHeaderView.layer;

    if (on) {
        layer.shadowColor = [[UIColor darkGrayColor] CGColor];     
    } else {
        layer.shadowColor = [[UIColor clearColor] CGColor];
    }
}

@end
