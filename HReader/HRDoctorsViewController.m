//
//  HRDoctorsViewController.m
//  HReader
//
//  Created by Marshall Huss on 12/2/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRDoctorsViewController.h"
#import "HRPatientSwipeControl.h"
#import "HRMPatient.h"

@interface HRDoctorsViewController ()
- (void)reloadData;
- (void)reloadDataAnimated;
@end

@implementation HRDoctorsViewController

@synthesize nameLabel                   = __nameLabel;
@synthesize tapGesture;

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.title = @"Doctors";
    }
    return self;
}
- (void)dealloc {
    [__nameLabel release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // load patient swipe
    HRPatientSwipeControl *swipe = [HRPatientSwipeControl
                                    controlWithOwner:self
                                    options:nil 
                                    target:self
                                    action:@selector(patientChanged:)];
    [self.view addSubview:swipe];
    
    // Doctor detail view

//    [self.view addSubview:self.doctorDetailView];
//    self.doctorDetailView.alpha = 0.0;
//    
//    // Border
//    self.doctorImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
//    self.doctorImageView.layer.borderWidth = 3.0f;
//    
//    // Shadow
//    self.doctorImageView.layer.shadowColor = [[UIColor blackColor] CGColor];
//    self.doctorImageView.layer.shadowOpacity = 0.5f;
//    self.doctorImageView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
//    self.doctorImageView.layer.shadowRadius = 5.0f;
//    self.doctorImageView.layer.shouldRasterize = YES;
    
    [self reloadData];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.nameLabel = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

//- (IBAction)showDoctor:(id)sender {
//    [TestFlight passCheckpoint:@"Show Doctor"];
////    [UIView animateWithDuration:1.0 animations:^{
////        self.doctorDetailView.alpha = 1.0;
////    }];
//    UIViewController *vc = [[UIViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
//    [vc release];
//}
//
//- (IBAction)hideDoctor:(id)sender {
//    [TestFlight passCheckpoint:@"Hide Doctor"];
//    [UIView animateWithDuration:1.0 animations:^{
//        self.doctorDetailView.alpha = 0.0;
//    }];    
//}

#pragma mark - NSNotificationCenter

- (void)patientChanged:(HRPatientSwipeControl *)sender {
    [self reloadDataAnimated];
}

#pragma mark - private methods

- (void)reloadDataAnimated {
    [UIView animateWithDuration:0.4 animations:^{
        self.nameLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self reloadData];
        [UIView animateWithDuration:0.4 animations:^{
            self.nameLabel.alpha = 1.0;
        }];
    }];       
}

- (void)reloadData {
    HRMPatient *patient = [HRMPatient selectedPatient];
    self.nameLabel.text = [patient compositeName];
}

@end
