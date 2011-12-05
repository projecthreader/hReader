//
//  HRDoctorsViewController.m
//  HReader
//
//  Created by Marshall Huss on 12/2/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRDoctorsViewController.h"

@implementation HRDoctorsViewController
@synthesize patientImageShadowView      = __patientImageShadowView;
@synthesize patientImageView            = __patientImageView;
@synthesize doctorImageView             = __doctorImageView;

- (void)dealloc {
    [__patientImageShadowView release];
    [__patientImageView release];
    [__doctorImageView release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Doctors";
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Border
//    self.doctorImageView.clipsToBounds = NO;
    self.doctorImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.doctorImageView.layer.borderWidth = 3.0f;
    
    // Shadow
    self.doctorImageView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.doctorImageView.layer.shadowOpacity = 0.5f;
    self.doctorImageView.layer.shadowOffset = CGSizeMake(2.0f, 0.0f);
    self.doctorImageView.layer.shadowRadius = 5.0f;

     [HRConfig setShadowForView:self.patientImageShadowView borderForView:self.patientImageView];   
}

- (void)viewDidUnload {
    [self setPatientImageShadowView:nil];
    [self setPatientImageView:nil];
    [self setDoctorImageView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
