//
//  HRPatientSummarySplitViewController.m
//  HReader
//
//  Created by Marshall Huss on 11/30/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRPatientSummaryViewController.h"


@interface HRPatientSummaryViewController ()
- (void)toggleViewShadow:(BOOL)on;
@end

@implementation HRPatientSummaryViewController

@synthesize patientHeaderView       = __patientHeaderView;
@synthesize patientImageShadowView  = __patientImageShadowView;
@synthesize patientImageView        = __patientImageView;
@synthesize patientScrollView       = __patientScrollView;
@synthesize patientSummaryView      = __patientSummaryView;


- (void)dealloc {
    [__patientImageView release];
    [__patientScrollView release];
    [__patientSummaryView release];
    [__patientHeaderView release];
    [__patientImageShadowView release];
    
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
    
    // Shadow for patient image
    [HRConfig setShadowForView:self.patientImageShadowView borderForView:self.patientImageView];
    
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
    
}

- (void)viewDidUnload {
    [self setPatientImageView:nil];
    [self setPatientScrollView:nil];
    [self setPatientSummaryView:nil];
    [self setPatientHeaderView:nil];
    [self setPatientImageShadowView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y != 0) {
        [self toggleViewShadow:YES];
    } else {
        [self toggleViewShadow:NO];
    }
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
