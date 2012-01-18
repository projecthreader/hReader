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

@synthesize patientHeaderView                   = __patientHeaderView;
@synthesize patientScrollView                   = __patientScrollView;
@synthesize patientSummaryView                  = __patientSummaryView;

@synthesize patientName                         = __patientName;
@synthesize dobLabel                            = __dobLabel;

@synthesize labelsArray                         = __labelsArray;
@synthesize allergiesLabel                      = __allergiesLabel;
@synthesize recentConditionsDateLabel           = __rececentConditionsDateLabel;
@synthesize recentConditionsLabel               = __recentConditionsLabel;
@synthesize chronicConditionsLabel              = __chronicConditionsLabel;
@synthesize upcomingEventsLabel                 = __upcomingEventsLabel;
@synthesize planOfCareLabel                     = __planOfCareLabel;
@synthesize followUpAppointmentLabel            = __followUpAppointmentLabel;
@synthesize medicationRefillLabel               = __medicationRefillLabel;
@synthesize recentEncountersDateLabel           = __recentEncountersDateLabel;
@synthesize recentEncountersTypeLabel           = __recentEncountersTypeLabel;
@synthesize recentEncountersDescriptionLabel    = __recentEncountersDescriptionLabel;
@synthesize immunizationsUpToDateLabel          = __immunizationsUpToDateLabel;
@synthesize currentMedicationsLabel             = __currentMedicationsLabel;
@synthesize currentMedicationsDosageLabel       = __currentMedicationsDosageLabel;
@synthesize functionalStatusDateLabel           = __functionalStatusDateLabel;
@synthesize functionalStatusTypeLabel           = __functionalStatusTypeLabel;
@synthesize functionalStatusProblemLabel        = __functionalStatusProblemLabel;
@synthesize functionalStatusStatusLabel         = __functionalStatusStatusLabel;
@synthesize heightTitleLabel                    = __heightTitleLabel;
@synthesize heightLabel                         = __heightLabel;
@synthesize heightDateLabel                     = __heightDateLabel;
@synthesize heightNormalLabel                   = __heightNormalLabel;
@synthesize weightLabel                         = __weightLabel;
@synthesize weightDateLabel                     = __weightDateLabel;
@synthesize weightNormalLabel                   = __weightNormalLabel;
@synthesize bmiLabel                            = __bmiLabel;
@synthesize bmiDateLabel                        = __bmiDateLabel;
@synthesize bmiNormalLabel                      = __bmiNormalLabel;
@synthesize pulseLabel                          = __pulseLabel;
@synthesize pulseDateLabel                      = __pulseDate;
@synthesize pulseNormalLabel                    = __pulseNormalLabel;
@synthesize advanceDirectivesLabel              = __advanceDirectivesLabel;
@synthesize diagnosisLabel                      = __diagnosisLabel;
@synthesize diagnosisDateLabel                  = __diagnosisDateLabel;
@synthesize heightImageView                     = __heightImageView;
@synthesize weightImageView                     = __weightImageView;
@synthesize bmiImageView                        = __bmiImageView;
@synthesize pulseImageView                      = __pulseImageView;


- (void)dealloc {
    [__patientSummaryView release];
    [__patientScrollView release];
    [__patientSummaryView release];
    [__patientHeaderView release];
    [__dobLabel release];
    
    [__labelsArray release];

    [__allergiesLabel release];
    [__rececentConditionsDateLabel release];
    [__recentConditionsLabel release];
    [__chronicConditionsLabel release];
    [__upcomingEventsLabel release];
    [__planOfCareLabel release];
    [__followUpAppointmentLabel release];
    [__medicationRefillLabel release];
    [__recentEncountersDateLabel release];
    [__recentEncountersTypeLabel release];
    [__recentEncountersDescriptionLabel release];
    [__immunizationsUpToDateLabel release];
    [__currentMedicationsLabel release];
    [__currentMedicationsDosageLabel release];
    [__functionalStatusDateLabel release];
    [__functionalStatusTypeLabel release];
    [__functionalStatusProblemLabel release];
    [__functionalStatusStatusLabel release];
    [__heightLabel release];
    [__heightDateLabel release];
    [__heightNormalLabel release];
    [__weightLabel release];
    [__weightDateLabel release];
    [__weightNormalLabel release];
    [__bmiLabel release];
    [__bmiDateLabel release];
    [__bmiNormalLabel release];
    [__pulseLabel release];
    [__pulseDate release];
    [__pulseNormalLabel release];
    [__advanceDirectivesLabel release];
    [__diagnosisLabel release];
    [__diagnosisDateLabel release];
    [__heightTitleLabel release];
    [__heightImageView release];
    [__weightImageView release];
    [__bmiImageView release];
    [__pulseImageView release];
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
    
    self.labelsArray = [NSArray arrayWithObjects:self.patientName, self.dobLabel, self.allergiesLabel, self.recentConditionsDateLabel, self.recentConditionsLabel, self.chronicConditionsLabel, self.upcomingEventsLabel, self.planOfCareLabel, self.followUpAppointmentLabel, self.medicationRefillLabel, self.recentEncountersDateLabel, self.recentEncountersTypeLabel, self.recentEncountersDescriptionLabel, self.immunizationsUpToDateLabel, self.currentMedicationsLabel, self.currentMedicationsDosageLabel, self.functionalStatusDateLabel, self.functionalStatusTypeLabel, self.functionalStatusProblemLabel, self.functionalStatusStatusLabel, self.heightTitleLabel, self.heightLabel, self.heightDateLabel, self.heightNormalLabel, self.weightLabel, self.weightDateLabel, self.weightNormalLabel, self.bmiLabel, self.bmiDateLabel, self.bmiNormalLabel, self.pulseLabel, self.pulseDateLabel, self.pulseNormalLabel, self.advanceDirectivesLabel, self.diagnosisLabel, self.diagnosisDateLabel, self.heightImageView, self.bmiImageView, self.pulseImageView, self.weightImageView, nil];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(patientChanged:) 
                                                 name:HRPatientDidChangeNotification 
                                               object:nil];
    
}

- (void)viewDidUnload {
    self.patientSummaryView = nil;
    self.patientScrollView = nil;
    self.patientSummaryView = nil;
    self.patientHeaderView = nil;    
    self.patientName = nil;
    
    [self setDobLabel:nil];
    
    [self setAllergiesLabel:nil];
    [self setRecentConditionsDateLabel:nil];
    [self setRecentConditionsLabel:nil];
    [self setChronicConditionsLabel:nil];
    [self setUpcomingEventsLabel:nil];
    [self setPlanOfCareLabel:nil];
    [self setFollowUpAppointmentLabel:nil];
    [self setMedicationRefillLabel:nil];
    [self setRecentEncountersDateLabel:nil];
    [self setRecentEncountersTypeLabel:nil];
    [self setRecentEncountersDescriptionLabel:nil];
    [self setImmunizationsUpToDateLabel:nil];
    [self setCurrentMedicationsLabel:nil];
    [self setCurrentMedicationsDosageLabel:nil];
    [self setFunctionalStatusDateLabel:nil];
    [self setFunctionalStatusTypeLabel:nil];
    [self setFunctionalStatusProblemLabel:nil];
    [self setFunctionalStatusStatusLabel:nil];
    [self setHeightLabel:nil];
    [self setHeightDateLabel:nil];
    [self setHeightNormalLabel:nil];
    [self setWeightLabel:nil];
    [self setWeightDateLabel:nil];
    [self setWeightNormalLabel:nil];
    [self setBmiLabel:nil];
    [self setBmiDateLabel:nil];
    [self setBmiNormalLabel:nil];
    [self setPulseLabel:nil];
    [self setPulseDateLabel:nil];
    [self setPulseNormalLabel:nil];
    [self setAdvanceDirectivesLabel:nil];
    [self setDiagnosisLabel:nil];
    [self setDiagnosisDateLabel:nil];
    [self setHeightTitleLabel:nil];
    [self setHeightImageView:nil];
    [self setWeightImageView:nil];
    [self setBmiImageView:nil];
    [self setPulseImageView:nil];
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
    
//    HRAddress *address = patient.address;
    
    [UIView animateWithDuration:0.4 animations:^{
        [self.labelsArray setValue:[NSNumber numberWithDouble:0.0] forKey:@"alpha"];
    } completion:^(BOOL finished) {
        self.patientName.text = [patient.name uppercaseString];
        self.dobLabel.text = [patient dateOfBirthString];
        self.allergiesLabel.text = [[patient.info objectForKey:@"allergies"] componentsJoinedByString:@"\n"];
        self.recentConditionsLabel.text = [patient.info objectForKey:@"recent_condition"];
        self.recentConditionsDateLabel.text = [patient.info objectForKey:@"recent_condition_date"];
        self.chronicConditionsLabel.text = [[patient.info objectForKey:@"chronic_conditions"] componentsJoinedByString:@"\n"];
        self.upcomingEventsLabel.text = [patient.info objectForKey:@"upcoming_events"];
        self.planOfCareLabel.text = [patient.info objectForKey:@"plan_of_care"];
        self.followUpAppointmentLabel.text = [patient.info objectForKey:@"follow_up_appointment"];
        self.medicationRefillLabel.text = [patient.info objectForKey:@"medication_refill"];
        self.recentEncountersDateLabel.text = [patient.info objectForKey:@"recent_encounters_date"];
        self.recentEncountersTypeLabel.text = [patient.info objectForKey:@"recent_encounters_type"];
        self.recentEncountersDescriptionLabel.text = [patient.info objectForKey:@"recent_encounters_description"];
        self.immunizationsUpToDateLabel.text = [patient.info objectForKey:@"immunizations"];
        
        self.heightTitleLabel.text = [[patient.info objectForKey:@"height_title_label"] uppercaseString];
        self.heightLabel.text = [patient.info objectForKey:@"height"];
        self.heightDateLabel.text = [patient.info objectForKey:@"height_date"];
        self.heightNormalLabel.text = [patient.info objectForKey:@"height_normal"];
        self.weightLabel.text = [patient.info objectForKey:@"weight"];
        self.weightDateLabel.text = [patient.info objectForKey:@"weight_date"];
        self.weightNormalLabel.text = [patient.info objectForKey:@"weight_normal"];
        self.bmiLabel.text = [patient.info objectForKey:@"bmi"];
        self.bmiDateLabel.text = [patient.info objectForKey:@"bmi_date"];
        self.bmiNormalLabel.text = [patient.info objectForKey:@"bmi_normal"];
        self.pulseLabel.text = [patient.info objectForKey:@"pulse"];
        self.pulseDateLabel.text = [patient.info objectForKey:@"pulse_date"];
        self.pulseNormalLabel.text = [patient.info objectForKey:@"pulse_normal"];
        self.currentMedicationsLabel.text = [[[patient.info objectForKey:@"medications"] allValues] componentsJoinedByString:@"\n"];
        self.currentMedicationsDosageLabel.text = [[[patient.info objectForKey:@"medications"] allKeys] componentsJoinedByString:@"\n"];
        self.functionalStatusDateLabel.text = [patient.info objectForKey:@"functional_status_date"];
        self.functionalStatusProblemLabel.text = [patient.info objectForKey:@"functional_status_problem"];
        self.functionalStatusStatusLabel.text = [patient.info objectForKey:@"functional_status_status"];
        self.functionalStatusTypeLabel.text = [patient.info objectForKey:@"functional_status_type"];
        self.diagnosisLabel.text = [patient.info objectForKey:@"diagnosis_results"];
        self.diagnosisDateLabel.text = [patient.info objectForKey:@"diagnosis_date"];
        
        self.heightImageView.image = [patient.info objectForKey:@"height_sparklines"];
        self.bmiImageView.image = [patient.info objectForKey:@"bmi_sparklines"];
        self.pulseImageView.image = [patient.info objectForKey:@"pulse_sparklines"];
        self.weightImageView.image = [patient.info objectForKey:@"weight_sparklines"];
        
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
