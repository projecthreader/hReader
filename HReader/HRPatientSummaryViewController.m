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
#import "HRVitalView.h"
#import "HRVital.h"

@interface HRPatientSummaryViewController ()
- (void)reloadDataAnimated;
- (void)toggleViewShadow:(BOOL)on;
- (void)reloadData;
@end

@implementation HRPatientSummaryViewController

@synthesize patientHeaderView                   = __patientHeaderView;
@synthesize patientScrollView                   = __patientScrollView;
@synthesize patientSummaryView                  = __patientSummaryView;

@synthesize patientName                         = __patientName;
@synthesize dobLabel                            = __dobLabel;

@synthesize labelsArray                         = __labelsArray;
@synthesize vitalsViewsArray                    = __vitalsViewsArray;

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
@synthesize pulseLabel                          = __pulseLabel;
@synthesize pulseDateLabel                      = __pulseDate;
@synthesize pulseNormalLabel                    = __pulseNormalLabel;
@synthesize advanceDirectivesLabel              = __advanceDirectivesLabel;
@synthesize diagnosisLabel                      = __diagnosisLabel;
@synthesize diagnosisDateLabel                  = __diagnosisDateLabel;
@synthesize pulseImageView                      = __pulseImageView;
@synthesize vital1View                          = __vital1View;
@synthesize vital2View                          = __vital2View;
@synthesize vital3View                          = __vital3View;


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [__patientSummaryView release];
    [__patientScrollView release];
    [__patientSummaryView release];
    [__patientHeaderView release];
    [__dobLabel release];
    
    [__labelsArray release];
    [__vitalsViewsArray release];
    
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
    [__pulseLabel release];
    [__pulseDate release];
    [__pulseNormalLabel release];
    [__advanceDirectivesLabel release];
    [__diagnosisLabel release];
    [__diagnosisDateLabel release];
    [__pulseImageView release];
    [__vital1View release];
    [__vital2View release];
    [__vital3View release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        HRPatientSwipeViewController *patientSwipeViewController = [[HRPatientSwipeViewController alloc] initWithNibName:nil bundle:nil];
        [self addChildViewController:patientSwipeViewController];
        patientSwipeViewController.patientsArray = [HRConfig patients];
        [patientSwipeViewController release];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(patientChanged:) name:HRPatientDidChangeNotification object:nil];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.labelsArray = [NSArray arrayWithObjects:self.patientName, self.dobLabel, self.allergiesLabel, self.recentConditionsDateLabel, self.recentConditionsLabel, self.chronicConditionsLabel, self.upcomingEventsLabel, self.planOfCareLabel, self.followUpAppointmentLabel, self.medicationRefillLabel, self.recentEncountersDateLabel, self.recentEncountersTypeLabel, self.recentEncountersDescriptionLabel, self.immunizationsUpToDateLabel, self.currentMedicationsLabel, self.currentMedicationsDosageLabel, self.functionalStatusDateLabel, self.functionalStatusTypeLabel, self.functionalStatusProblemLabel, self.functionalStatusStatusLabel, self.heightTitleLabel, self.heightLabel, self.heightDateLabel, self.heightNormalLabel, self.weightLabel, self.weightDateLabel, self.weightNormalLabel, self.bmiLabel, self.bmiDateLabel, self.bmiNormalLabel, self.pulseLabel, self.pulseDateLabel, self.pulseNormalLabel, self.advanceDirectivesLabel, self.diagnosisLabel, self.diagnosisDateLabel, self.heightImageView, self.bmiImageView, self.pulseImageView, self.weightImageView, nil];
    
//    [self.labelsArray setValue:[NSNumber numberWithDouble:0.0] forKeyPath:@"alpha"];
    
    HRPatientSwipeViewController *patientSwipeViewController = (HRPatientSwipeViewController *)[self.childViewControllers objectAtIndex:0];
    patientSwipeViewController.selectedPatient = [HRConfig selectedPatient];
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

    [self toggleViewShadow:YES];
    
    UINib *nib = [UINib nibWithNibName:@"HRVitalView" bundle:nil];
    self.vitalsViewsArray = [NSArray arrayWithObjects:self.vital1View, self.vital2View, self.vital3View, nil];
    [self.vitalsViewsArray enumerateObjectsUsingBlock:^(HRVitalView *view, NSUInteger idx, BOOL *stop) {
        HRVitalView *vitalView = [[nib instantiateWithOwner:self options:nil] lastObject];
        vitalView.frame = self.vital1View.bounds;
        [view addSubview:vitalView]; 
    }];
    
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
    [self setPulseLabel:nil];
    [self setPulseDateLabel:nil];
    [self setPulseNormalLabel:nil];
    [self setAdvanceDirectivesLabel:nil];
    [self setDiagnosisLabel:nil];
    [self setDiagnosisDateLabel:nil];
    [self setPulseImageView:nil];
    [self setVital1View:nil];
    [self setVital2View:nil];
    [self setVital3View:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView.contentOffset.y > 0) {
//        [self toggleViewShadow:YES];
//    } else {
//        [self toggleViewShadow:NO];
//    }
}

#pragma mark - NSNotificationCenter

- (void)patientChanged:(NSNotification *)notif {
    [self reloadDataAnimated];
}


#pragma mark - Private methods

- (void)reloadDataAnimated {
    [UIView animateWithDuration:0.4 animations:^{
        [self.labelsArray setValue:[NSNumber numberWithDouble:0.0] forKey:@"alpha"];
    } completion:^(BOOL finished) {
        [self reloadData];
        
        [UIView animateWithDuration:0.4 animations:^{
            [self.labelsArray setValue:[NSNumber numberWithDouble:1.0] forKey:@"alpha"];
        }];
    }];    
}

- (void)reloadData {
    HRPatient *patient = [HRConfig selectedPatient];
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
    
    self.pulseImageView.image = [patient.info objectForKey:@"pulse_sparklines"];
    
    
    [self.vitalsViewsArray enumerateObjectsUsingBlock:^(HRVitalView *view, NSUInteger idx, BOOL *stop) {
        if (idx < [[patient vitals] count]) {
            HRVital *vital = [[patient vitals] objectAtIndex:idx];
            HRVitalView *vitalView = [view.subviews lastObject];
            vitalView.vital = vital;            
        }
    }];

}

- (void)toggleViewShadow:(BOOL)on {
    CALayer *layer = self.patientHeaderView.layer;

    if (on) {
        layer.shadowOpacity = 0.5;
    } else {
        layer.shadowOpacity = 0.0;
    }
}

@end
