//
//  HRDoctorsViewController.m
//  HReader
//
//  Created by Marshall Huss on 12/2/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRDoctorsViewController.h"
#import "HRPatientSwipeViewController.h"

@implementation HRDoctorsViewController

@synthesize patientView                 = __patientView;
@synthesize doctorImageView             = __doctorImageView;

- (void)dealloc {
    [__patientView release];;
    [__doctorImageView release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Doctors";
        
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
    [self.patientView addSubview:patientSwipeViewController.view];
    
    // Border
//    self.doctorImageView.clipsToBounds = NO;
    self.doctorImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.doctorImageView.layer.borderWidth = 3.0f;
    
    // Shadow
    self.doctorImageView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.doctorImageView.layer.shadowOpacity = 0.5f;
    self.doctorImageView.layer.shadowOffset = CGSizeMake(2.0f, 0.0f);
    self.doctorImageView.layer.shadowRadius = 5.0f;

//     [HRConfig setShadowForView:self.patientImageShadowView borderForView:self.patientImageView];   
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.patientView = nil;
    self.doctorImageView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
