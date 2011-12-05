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
- (void)setHeaderViewShadow;
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
    
    [HRConfig setShadowForView:self.patientImageShadowView borderForView:self.patientImageView];
    [self setHeaderViewShadow];
    
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



#pragma mark - Private methods

- (void)setHeaderViewShadow {
    CALayer *layer = self.patientHeaderView.layer;
    layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    layer.shadowOpacity = 0.5;
    layer.shadowOffset = CGSizeMake(0, 3);
    layer.masksToBounds = NO;
    [self.view bringSubviewToFront:self.patientHeaderView];    
}

@end
