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
#import "HRMPatient.h"
#import "HRAddress.h"
#import "HRVitalView.h"
#import "HRVital.h"
#import "HRMEntry.h"
#import "HRBMI.h"
#import "HRMedicationsAppletTile.h"

#import "NSDate+FormattedDate.h"
#import "NSArray+Collect.h"

@interface HRPatientSummaryViewController () {
@private
    NSArray * __strong __gridViews;
}

- (void)reloadData;

@end

@implementation HRPatientSummaryViewController

@synthesize gridView = __gridView;
@synthesize headerView = __headerView;

@synthesize patientNameLabel                    = __patientNameLabel;
@synthesize dateOfBirthLabel                    = __dateOfBirthLabel;
@synthesize dateOfBirthTitleLabel               = __dateOfBirthTitleLabel;
@synthesize allergiesLabel                      = __allergiesLabel;
@synthesize recentConditionsDateLabel           = __rececentConditionsDateLabel;
@synthesize recentConditionsLabel               = __recentConditionsLabel;
@synthesize chronicConditionsLabel              = __chronicConditionsLabel;
@synthesize followUpAppointmentLabel            = __followUpAppointmentLabel;
@synthesize medicationRefillLabel               = __medicationRefillLabel;
@synthesize upcomingEventsLabel                 = __upcomingEventsLabel;
@synthesize planOfCareLabel                     = __planOfCareLabel;


@synthesize labels              = __labels;

@synthesize medicationNameLabels                = __medicationNameLabels;
@synthesize medicationDosageLabels              = __medicationDosageLabels;

@synthesize vitalViews                          = __vitalViews;






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

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.title = @"Summary";
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(didEnterBackground:)
         name:UIApplicationDidEnterBackgroundNotification
         object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadData {
    
    // get patient
    HRMPatient *patient = [HRMPatient selectedPatient];
    
    // grid view
    {
        
        // create container
        NSMutableArray *views = [NSMutableArray array];
        
        // vitals
        {
            NSDictionary *vitals = [patient vitalSignsGroupedByDescription];
            [vitals enumerateKeysAndObjectsUsingBlock:^(NSString *type, NSArray *entries, BOOL *stop) {
                HRVitalView *view = [HRVitalView tile];
                if ([type isEqualToString:@"BMI"]) {
                    view.vital = [[HRBMI alloc] initWithEntries:entries];
                }
                else  {
                    view.vital = [[HRVital alloc] initWithEntries:entries];
                }
                [views addObject:view];
            }];
        }
        
        // medications
        {
            HRMedicationsAppletTile *medicationsTile = [HRMedicationsAppletTile tile];
            medicationsTile.medications = [patient medications];
            [views addObject:medicationsTile];

        }
        
        // save and reload
        __gridViews = views;
        [self.gridView reloadData];
        
    }
    
    {
//        NSArray *providers = [[HRMPatient selectedPatient] valueForKeyPath:@"syntheticInfo.providers"];
        
        NSDictionary *syntheticInfo = patient.syntheticInfo;
//        NSString *noData = @"Not in PDS";        

        // synthetic info
        
        // immunizations
        if ([[syntheticInfo objectForKey:@"immunizations"] boolValue]) {
            self.immunizationsUpToDateLabel.text = @"Yes";
            self.immunizationsUpToDateLabel.textColor = [HRConfig greenColor];
        }
        else {
            self.immunizationsUpToDateLabel.text = @"No";
            self.immunizationsUpToDateLabel.textColor = [HRConfig redColor];
        }
        
        // recents conditions
        NSDictionary *recentCondition = [[syntheticInfo objectForKey:@"conditions"] lastObject];
        self.recentConditionsLabel.text = [recentCondition objectForKey:@"title"];
        self.recentConditionsDateLabel.text = [recentCondition objectForKey:@"description"];
        self.chronicConditionsLabel.text = [[syntheticInfo objectForKey:@"chronic_conditions"] componentsJoinedByString:@", "];
        
        // upcoming events
        NSDictionary *upcomingEvent = [[syntheticInfo objectForKey:@"upcoming_events"] lastObject];
        self.upcomingEventsLabel.text = [upcomingEvent objectForKey:@"title"];
        self.planOfCareLabel.text = [upcomingEvent objectForKey:@"plan_of_care"];
        self.followUpAppointmentLabel.text = [self formattedDate:[[upcomingEvent objectForKey:@"follow_up_appointment_date"] doubleValue]];
        self.medicationRefillLabel.text = [upcomingEvent objectForKey:@"medication_refill"];
        
        // functional status
        NSDictionary *functionalStatus = [syntheticInfo objectForKey:@"functional_status"];
        self.functionalStatusDateLabel.text = [self formattedDate:[[functionalStatus objectForKey:@"date"] doubleValue]];
        self.functionalStatusProblemLabel.text = [functionalStatus objectForKey:@"problem"];
        self.functionalStatusStatusLabel.text = [functionalStatus objectForKey:@"status"];
        self.functionalStatusTypeLabel.text = [functionalStatus objectForKey:@"type"];;
        
        // advanced directives
        self.advanceDirectivesLabel.text = [syntheticInfo objectForKey:@"advanced_directives"];
        
        // diagnosis
        NSDictionary *diagnosis = [syntheticInfo objectForKey:@"diagnosis"];
        self.diagnosisDateLabel.text = [self formattedDate:[[diagnosis objectForKey:@"results"] doubleValue]];
        self.diagnosisLabel.text = [diagnosis objectForKey:@"results"];
        
        
        // PDS data
        self.patientNameLabel.text = [[patient compositeName] uppercaseString];
        if ([self.dateOfBirthTitleLabel.text isEqualToString:@"DOB"]) {
            self.dateOfBirthLabel.text = [patient.dateOfBirth mediumStyleDate];
        }
        else {
            self.dateOfBirthLabel.text = [patient.dateOfBirth ageString];
        }
        
        // allergies
//        NSArray *allergies = patient.allergies;
//        NSUInteger allergiesCount = [allergies count];
//        self.allergiesLabel.textColor = [HRConfig redColor];
//        if (allergiesCount == 0) {
//            self.allergiesLabel.text = @"None";
//        }
//        else {
//            NSMutableString *allergiesString = [[[[allergies objectAtIndex:0] desc] mutableCopy] autorelease];
//            if (allergiesCount > 1) {
//                [allergiesString appendFormat:@", %lu more", (unsigned long)allergiesCount];
//            }
//            if ([allergiesString length] > 0) {
//                self.allergiesLabel.text = allergiesString;
//            }
//            else {
//                self.allergiesLabel.text = @"None";
//            }
//        }
        
        
        // medications
        
        
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
        

        
    }
    
    /*
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
    */
    
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
    
    // configure grid view
    self.gridView.numberOfColumns = 3;
    self.gridView.horizontalPadding = 34.0;
    self.gridView.verticalPadding = 42.0;
    
    // header shadow view
    CALayer *layer = self.headerView.layer;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOpacity = 0.5;
    layer.shadowOffset = CGSizeMake(0.0, 0.0);
    layer.shadowRadius = 5.0;
    layer.shouldRasterize = YES;
    [self.view bringSubviewToFront:self.headerView];
    
    // date of birth tap
    NSArray *array = [NSArray arrayWithObjects:self.dateOfBirthLabel, self.dateOfBirthTitleLabel, nil];
    [array enumerateObjectsUsingBlock:^(UIView *view, NSUInteger index, BOOL *stop) {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(toggleDateOfBirth:)];
        [view addGestureRecognizer:gesture];
    }];
    
}

- (void)viewDidUnload {
    
    // release other outlets
    self.headerView = nil;
    self.gridView = nil;
    self.headerView = nil;
    self.patientNameLabel = nil;
    self.dateOfBirthTitleLabel = nil;
    self.dateOfBirthLabel = nil;
    self.recentConditionsLabel = nil;
    self.recentConditionsDateLabel = nil;
    self.chronicConditionsLabel = nil;
    self.allergiesLabel = nil;
    self.followUpAppointmentLabel = nil;
    self.medicationRefillLabel = nil;
    self.planOfCareLabel = nil;
    self.upcomingEventsLabel = nil;
    
    
    
    
    self.labels = nil;
    self.medicationDosageLabels = nil;
    self.medicationNameLabels = nil;
    self.vitalViews = nil;
    
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
    
    // super
    [super viewDidUnload];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - grid view delegate

- (NSInteger)numberOfViewsInGridView:(HRGridTableView *)gridView {
    return [__gridViews count];
}

- (NSArray *)gridView:(HRGridTableView *)gridView viewsInRange:(NSRange)range {
    return [__gridViews subarrayWithRange:range];
}

- (void)gridView:(HRGridTableView *)gridView didSelectViewAtIndex:(NSInteger)index {
    HRAppletTile *tile = [__gridViews objectAtIndex:index];
    CGRect rect = [self.view convertRect:tile.bounds fromView:tile];
    [tile didReceiveTap:self inRect:rect];
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

#pragma mark - tap gestures

- (void)toggleDateOfBirth:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if ([self.dateOfBirthTitleLabel.text isEqualToString:@"DOB"]) {
            self.dateOfBirthTitleLabel.text = @"AGE";
        }
        else {
            self.dateOfBirthTitleLabel.text = @"DOB";
        }
        [self reloadData];
    }
}

#pragma mark - notifs

- (void)didEnterBackground:(NSNotification *)notif {
//    [self.popoverController dismissPopoverAnimated:NO];
}

#pragma mark - private

- (NSString *)formattedDate:(double)interval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    return [date mediumStyleDate];
}

@end
