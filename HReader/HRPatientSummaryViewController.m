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
@synthesize genderLabel                 = __genderLabel;
@synthesize ageLabel                    = __ageLabel;
@synthesize dobLabel                    = __dobLabel;
@synthesize placeOfBirthLabel           = __placeOfBirthLabel;
@synthesize raceLabel                   = __raceLabel;
@synthesize ethnicityLabel              = __ethnicityLabel;
@synthesize phoneNumberLabel            = __phoneNumberLabel;

@synthesize labelsArray                 = __labelsArray;


- (void)dealloc {
    [__patientSummaryView release];
    [__patientScrollView release];
    [__patientSummaryView release];
    [__patientHeaderView release];
    [__patientName release];
    [__addressLabel release];
    [__genderLabel release];
    [__ageLabel release];
    [__dobLabel release];
    [__placeOfBirthLabel release];
    [__raceLabel release];
    [__ethnicityLabel release];
    [__phoneNumberLabel release];
    
    [__labelsArray release];

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
    
    self.labelsArray = [NSArray arrayWithObjects:self.patientName, self.addressLabel, self.genderLabel, self.ageLabel, self.dobLabel, self.placeOfBirthLabel, self.raceLabel, self.ethnicityLabel, self.phoneNumberLabel, nil];
    [self.labelsArray setValue:[NSNumber numberWithDouble:0.0] forKeyPath:@"alpha"];
    
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
    self.genderLabel = nil;
    self.ageLabel = nil;
    
    [self setDobLabel:nil];
    [self setPlaceOfBirthLabel:nil];
    [self setRaceLabel:nil];
    [self setEthnicityLabel:nil];
    [self setPhoneNumberLabel:nil];
    
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
    
    HRAddress *address = patient.address;
    
    [UIView animateWithDuration:0.4 animations:^{
        [self.labelsArray setValue:[NSNumber numberWithDouble:0.0] forKey:@"alpha"];
    } completion:^(BOOL finished) {
        self.patientName.text = [patient.name uppercaseString];
        self.addressLabel.text = [NSString stringWithFormat:@"%@\n%@, %@ %@", address.street1, address.city, address.state, address.zip];
        self.genderLabel.text = [patient genderAsString];
        
        self.ageLabel.text = [patient age];
        self.dobLabel.text = [patient dateOfBirthString];
        self.placeOfBirthLabel.text = patient.placeOfBirth;
        self.raceLabel.text = patient.race;
        self.ethnicityLabel.text = patient.ethnicity;
        
        [UIView animateWithDuration:0.4 animations:^{
            [self.labelsArray setValue:[NSNumber numberWithDouble:1.0] forKey:@"alpha"];
        }];
    }];
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