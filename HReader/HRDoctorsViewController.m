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
#import "HRPatient.h"

@interface HRDoctorsViewController ()
- (void)reloadData;
- (void)reloadDataAnimated;
@end

@implementation HRDoctorsViewController

@synthesize doctorDetailView            = __doctorDetailView;
@synthesize patientView                 = __patientView;
@synthesize nameLabel                   = __nameLabel;
@synthesize doctorImageView             = __doctorImageView;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [__patientView release];;
    [__doctorImageView release];
    [__doctorDetailView release];
    [__nameLabel release];
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(patientChanged:) 
                                                     name:HRPatientDidChangeNotification 
                                                   object:nil];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HRPatientSwipeViewController *patientSwipeViewController = (HRPatientSwipeViewController *)[self.childViewControllers objectAtIndex:0];
    patientSwipeViewController.selectedPatient = [HRConfig selectedPatient];
    [self.view addSubview:patientSwipeViewController.view];
    
    // Doctor detail view

    [self.view addSubview:self.doctorDetailView];
    self.doctorDetailView.alpha = 0.0;
    
    // Border
    self.doctorImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.doctorImageView.layer.borderWidth = 3.0f;
    
    // Shadow
    self.doctorImageView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.doctorImageView.layer.shadowOpacity = 0.5f;
    self.doctorImageView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.doctorImageView.layer.shadowRadius = 5.0f;
    self.doctorImageView.layer.shouldRasterize = YES;
    
    [self reloadData];
}

- (void)viewDidUnload {
    [self setDoctorDetailView:nil];
    [self setNameLabel:nil];
    [super viewDidUnload];
    
    self.patientView = nil;
    self.doctorImageView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (IBAction)showDoctor:(id)sender {
    [TestFlight passCheckpoint:@"Show Doctor"];
    [UIView animateWithDuration:1.0 animations:^{
        self.doctorDetailView.alpha = 1.0;
    }];
}

- (IBAction)hideDoctor:(id)sender {
    [TestFlight passCheckpoint:@"Hide Doctor"];
    [UIView animateWithDuration:1.0 animations:^{
        self.doctorDetailView.alpha = 0.0;
    }];    
}

#pragma mark - NSNotificationCenter

- (void)patientChanged:(NSNotification *)notif {
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
    HRPatient *patient = [HRConfig selectedPatient];
    self.nameLabel.text = [patient.name uppercaseString];
}

@end
