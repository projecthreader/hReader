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
#import "HRAddress.h"

@interface HRPatientSummaryViewController ()
- (void)toggleViewShadow:(BOOL)on;
@end

@implementation HRPatientSummaryViewController

@synthesize patientHeaderView           = __patientHeaderView;
@synthesize patientScrollView           = __patientScrollView;
@synthesize patientSummaryView          = __patientSummaryView;

@synthesize patientName                 = __patientName;
@synthesize addressLabel                = __addressLabel;
@synthesize sexLabel                    = __sexLabel;


- (void)dealloc {
    [__patientSummaryView release];
    [__patientScrollView release];
    [__patientSummaryView release];
    [__patientHeaderView release];
    [__patientName release];
    [__addressLabel release];
    [__sexLabel release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        HRPatientSwipeViewController *patientSwipeViewController = [[HRPatientSwipeViewController alloc] initWithNibName:nil bundle:nil];
        [self addChildViewController:patientSwipeViewController];
        patientSwipeViewController.patientsArray = [HRConfig patients];
        [patientSwipeViewController release];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HRPatientSwipeViewController *patientSwipeViewController = (HRPatientSwipeViewController *)[self.childViewControllers objectAtIndex:0];
    [self.patientHeaderView addSubview:patientSwipeViewController.view];
    
    // Header shadow
    CALayer *layer = self.patientHeaderView.layer;
    layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    layer.shadowOpacity = 0.0;
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
    self.patientName = nil;
    self.addressLabel = nil;
    
    [self setSexLabel:nil];
    [super viewDidUnload];
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
    HRPatient *patient = [notif.userInfo objectForKey:HRPatientKey];
    self.patientName.text = [patient.name uppercaseString];
    
    HRAddress *address = patient.address;
    self.addressLabel.text = [NSString stringWithFormat:@"%@\n%@, %@ %@", address.street1, address.city, address.state, address.zip];
    self.sexLabel.text = [patient sexAsString];
}


#pragma mark - Private methods

- (void)toggleViewShadow:(BOOL)on {
    CALayer *layer = self.patientHeaderView.layer;

    if (on) {
        layer.shadowOpacity = 0.5;
    } else {
        layer.shadowOpacity = 0.0;
    }
}

@end
