//
//  HRPatientSummarySplitViewController.m
//  HReader
//
//  Created by Marshall Huss on 11/30/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRPatientSummaryViewController.h"
#import "HRPatientSwipeControl.h"
#import "HRRootViewController.h"
#import "HRPatient.h"
#import "HRMPatient.h"
#import "HRAddress.h"
#import "HRVitalView.h"
#import "HRVital.h"
#import "HRMEntry.h"
#import "HRBMI.h"

#import "NSDate+FormattedDate.h"

@interface HRPatientSummaryViewController ()
- (void)cleanup;
- (void)reloadData;
@end

@implementation HRPatientSummaryViewController

@synthesize scrollView          = __scrollView;
@synthesize headerView          = __headerView;
@synthesize contentView         = __contentView;
@synthesize footerShadowView    = __footerShadowView;

@synthesize labels              = __labels;

@synthesize medicationNameLabels                = __medicationNameLabels;
@synthesize medicationDosageLabels              = __medicationDosageLabels;

@synthesize vitalViews                          = __vitalViews;

@synthesize patientName                         = __patientName;
@synthesize dobLabel                            = __dobLabel;

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

#pragma mark - object methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Summary";
    }
    return self;
}
- (void)dealloc {
    [self cleanup];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [__dobLabel release];
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

    [super dealloc];
}
- (void)cleanup {
    self.scrollView = nil;
    self.headerView = nil;
    self.contentView = nil;
    self.footerShadowView = nil;
    self.labels = nil;
    self.medicationDosageLabels = nil;
    self.medicationNameLabels = nil;
    self.vitalViews = nil;
}
- (void)reloadData {
    
    {
        
        // these do not have meaningful data
        [self.medicationDosageLabels makeObjectsPerformSelector:@selector(setText:) withObject:nil];
        self.immunizationsUpToDateLabel.text = @"Unknown";
        
        // these are not
        HRMPatient *patient = [HRMPatient selectedPatient];
        self.patientName.text = [[patient compositeName] uppercaseString];
        self.dobLabel.text = [patient.dateOfBirth mediumStyleDate];
        
        // allergies
        NSArray *allergies = patient.allergies;
        NSUInteger allergiesCount = [allergies count];
        if (allergiesCount == 0) {
            self.allergiesLabel.text = @"None";
        }
        else {
            NSMutableString *allergiesString = [[[[allergies objectAtIndex:0] desc] mutableCopy] autorelease];
            if (allergiesCount > 1) {
                [allergiesString appendFormat:@", %lu more", (unsigned long)allergiesCount];
            }
            self.allergiesLabel.text = allergiesString;
        }
        
        // medications
        NSArray *medications = [patient medications];
        NSUInteger medicationsCount = [medications count];
        [self.medicationNameLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
            if (idx < medicationsCount) {
                HRMEntry *entry = [medications objectAtIndex:idx];
                label.text = entry.desc;
            }
            else {
                label.text = nil;
            }
        }];
        
        // encounters
        NSSortDescriptor *encounterSort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
        NSArray *encounters = [patient.encounters sortedArrayUsingDescriptors:[NSArray arrayWithObject:encounterSort]];
        HRMEntry *encounter = [encounters lastObject];
        self.recentEncountersDateLabel.text = [encounter.date mediumStyleDate];
        self.recentEncountersDescriptionLabel.text = encounter.desc;
        NSDictionary *codes = encounter.codes;
        NSDictionary *codeType = [[codes allKeys] lastObject];
        NSString *codeValues = [[codes objectForKey:codeType] componentsJoinedByString:@", "];
        self.recentEncountersTypeLabel.text = [NSString stringWithFormat:@"%@ %@", codeType, codeValues];
        
        // vitals
        NSDictionary *vitals = [patient vitalSignsGroupedByDescription];
        NSArray *vitalsKeys = [vitals allKeys];
        NSUInteger vitalsCount = [vitalsKeys count];
        [self.vitalViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
            if (idx < vitalsCount) {
                
                // unhide view
                view.hidden = NO;
                
                // get vital and vital view
                NSString *type = [vitalsKeys objectAtIndex:idx];
                NSArray *entries = [vitals objectForKey:type];
                HRVital *vital;
                if ([type isEqualToString:@"BMI"]) {
                    vital = [[[HRBMI alloc] initWithEntries:entries] autorelease];
                }
                else  {
                    vital = [[[HRVital alloc] initWithEntries:entries] autorelease];
                }
                
                // show vital
                [[view.subviews lastObject] showVital:vital];
                
            }
            else {
                view.hidden = YES;
            }
        }];
        
    }
    
    {
        HRPatient *patient = [HRConfig selectedPatient];
        self.recentConditionsLabel.text = [patient.info objectForKey:@"recent_condition"];
        self.recentConditionsDateLabel.text = [patient.info objectForKey:@"recent_condition_date"];
        self.chronicConditionsLabel.text = [[patient.info objectForKey:@"chronic_conditions"] componentsJoinedByString:@"\n"];
        self.upcomingEventsLabel.text = [patient.info objectForKey:@"upcoming_events"];
        self.planOfCareLabel.text = [patient.info objectForKey:@"plan_of_care"];
        self.followUpAppointmentLabel.text = [patient.info objectForKey:@"follow_up_appointment"];
        self.medicationRefillLabel.text = [patient.info objectForKey:@"medication_refill"];
        
        
        self.pulseLabel.text = [patient.info objectForKey:@"pulse"];
        self.pulseDateLabel.text = [patient.info objectForKey:@"pulse_date"];
        self.pulseNormalLabel.text = [patient.info objectForKey:@"pulse_normal"];
        self.functionalStatusDateLabel.text = [patient.info objectForKey:@"functional_status_date"];
        self.functionalStatusProblemLabel.text = [patient.info objectForKey:@"functional_status_problem"];
        self.functionalStatusStatusLabel.text = [patient.info objectForKey:@"functional_status_status"];
        self.functionalStatusTypeLabel.text = [patient.info objectForKey:@"functional_status_type"];
        self.diagnosisLabel.text = [patient.info objectForKey:@"diagnosis_results"];
        self.diagnosisDateLabel.text = [patient.info objectForKey:@"diagnosis_date"];
        self.pulseImageView.image = [patient.info objectForKey:@"pulse_sparklines"];
        
    }
    
}

#pragma mark - view methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // load patient swipe
    HRPatientSwipeControl *swipe = [HRPatientSwipeControl
                                    controlWithOwner:self
                                    options:nil 
                                    target:self
                                    action:@selector(patientChanged:)];
    [self.headerView addSubview:swipe];
    
    // configure scroll view
    CALayer *layer = self.contentView.layer;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOpacity = 0.5;
    layer.shadowRadius = 5.0;
    layer.shadowOffset = CGSizeMake(0.0, 0.0);
    layer.shouldRasterize = YES;
    self.scrollView.contentSize = self.contentView.frame.size;
    [self.scrollView addSubview:self.contentView];
    
    // configure footer shadow
    layer = self.footerShadowView.layer;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOpacity = 0.5;
    layer.shadowRadius = 5.0;
    layer.shadowOffset = CGSizeMake(0.0, 0.0);
    layer.shouldRasterize = YES;
    
    // header shadow
    layer = self.headerView.layer;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOpacity = 0.5;
    layer.shadowOffset = CGSizeMake(0.0, 0.0);
    layer.shadowRadius = 5.0;
    layer.shouldRasterize = YES;
    [self.view bringSubviewToFront:self.headerView];
    
    // load vital views
    UINib *nib = [UINib nibWithNibName:@"HRVitalView" bundle:nil];
    [self.vitalViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        view.backgroundColor = [UIColor clearColor];
        HRVitalView *vitalView = [[nib instantiateWithOwner:self options:nil] lastObject];
        vitalView.frame = view.bounds;
        [view addSubview:vitalView]; 
    }];
    
}
- (void)viewDidUnload {
    [self setVitalViews:nil];
    [super viewDidUnload];
    [self cleanup];
    
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
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - notifications

- (void)patientChanged:(HRPatientSwipeControl *)control {
    [UIView
     animateWithDuration:UINavigationControllerHideShowBarDuration
     animations:^{
         [self.labels setValue:[NSNumber numberWithDouble:0.0] forKey:@"alpha"];
     }
     completion:^(BOOL finished) {
         [self reloadData];
         [UIView animateWithDuration:0.4 animations:^{
             [self.labels setValue:[NSNumber numberWithDouble:1.0] forKey:@"alpha"];
         }];
     }];
}

@end
