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
#import "HRImageAppletTile.h"

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
    }
    return self;
}

- (void)reloadData {
    
    // get patient
    HRMPatient *patient = [HRMPatient selectedPatient];
    NSDictionary *syntheticInfo = patient.syntheticInfo;
    
    // date of birth
    self.patientNameLabel.text = [[patient compositeName] uppercaseString];
    if ([self.dateOfBirthTitleLabel.text isEqualToString:@"DOB"]) {
        self.dateOfBirthLabel.text = [patient.dateOfBirth mediumStyleDate];
    }
    else {
        self.dateOfBirthLabel.text = [patient.dateOfBirth ageString];
    }
    
    // allergies
    {
        NSArray *allergies = [patient.syntheticInfo objectForKey:@"allergies"];
        NSUInteger count = [allergies count];
        self.allergiesLabel.textColor = [UIColor blackColor];
        if (count) {
            NSMutableString *string = [[allergies objectAtIndex:0] mutableCopy];
            if (count > 1) {
                self.allergiesLabel.textColor = [HRConfig redColor];
                [string appendFormat:@", %lu more", (unsigned long)(count - 1)];
            }
            if ([string length] > 0) {
                self.allergiesLabel.textColor = [HRConfig redColor];
                self.allergiesLabel.text = string;
            }
            else {
                self.allergiesLabel.text = @"None";
            }
        }
        else { self.allergiesLabel.text = @"None"; }
    }
    /*
     {
     NSArray *allergies = patient.allergies;
     NSUInteger count = [allergies count];
     //    self.allergiesLabel.textColor = [HRConfig redColor];
     if (count) {
     NSMutableString *string = [[[allergies objectAtIndex:0] desc] mutableCopy];
     if (count > 1) {
     [string appendFormat:@", %lu more", (unsigned long)(count - 1)];
     }
     if ([string length] > 0) {
     self.allergiesLabel.text = string;
     }
     else {
     self.allergiesLabel.text = @"None";
     }
     }
     else { self.allergiesLabel.text = @"None"; }
     }
     */
    
    // chronic conditions
    {
        NSArray *conditions = [syntheticInfo objectForKey:@"chronic_conditions"];
        NSUInteger count = [conditions count];
        if (count) {
            NSString *condition = [conditions objectAtIndex:0];
            if ([condition length] > 0) {
                self.chronicConditionsLabel.text = condition;
            }
            else {
                self.chronicConditionsLabel.text = @"None";
            }
        }
        else { self.chronicConditionsLabel.text = @"None"; }
    }
    /*
     {
     NSArray *conditions = [syntheticInfo objectForKey:@"chronic_conditions"];
     NSUInteger count = [conditions count];
     if (count) {
     NSMutableString *string = [[conditions objectAtIndex:0] mutableCopy];
     if (count > 1) {
     [string appendFormat:@", %lu more", (unsigned long)(count - 1)];
     }
     if ([string length] > 0) {
     self.chronicConditionsLabel.text = string;
     }
     else {
     self.chronicConditionsLabel.text = @"None";
     }
     }
     else { self.chronicConditionsLabel.text = @"None"; }
     }
     */
    
    // recent conditions
    {
        NSArray *conditions = patient.conditions;
        if ([conditions count]) {
            HRMEntry *condition = [conditions lastObject];
            self.recentConditionsDateLabel.text = [condition.startDate mediumStyleDate];
            self.recentConditionsLabel.text = condition.desc;
        }
        else {
            self.recentConditionsDateLabel.text = @"None";
            self.recentConditionsLabel.text = nil;
        }
    }
    
    // upcoming events
    {
        NSDictionary *event = [[syntheticInfo objectForKey:@"upcoming_events"] lastObject];
        self.upcomingEventsLabel.text = [event objectForKey:@"title"];
        self.planOfCareLabel.text = [event objectForKey:@"plan_of_care"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[event objectForKey:@"follow_up_appointment_date"] doubleValue]];
        self.followUpAppointmentLabel.text = [date mediumStyleDate];
        NSDictionary *medication = [[event objectForKey:@"medication_refill"] lastObject];
        if (medication) {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[medication objectForKey:@"date"] doubleValue]];
            self.medicationRefillLabel.text = 
            [NSString stringWithFormat:@"%@ on %@",
             [medication objectForKey:@"medication"],
             [date mediumStyleDate]];
        }
        else {
            self.medicationRefillLabel.text = @"None";
        }
    }
    
    // grid view
    {
        
        // get list of applets for this patient
        NSMutableArray *views = [NSMutableArray array];
        NSURL *URL = [[NSBundle mainBundle] URLForResource:@"HReaderApplets" withExtension:@"plist"];
        NSArray *applets = [NSArray arrayWithContentsOfURL:URL];
        NSArray *identifiers = patient.applets;
        
        // load applets
        [identifiers enumerateObjectsUsingBlock:^(NSString *identifier, NSUInteger index, BOOL *stop) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier like %@", identifier];
            NSDictionary *dictionary = [[applets filteredArrayUsingPredicate:predicate] lastObject];
            if (dictionary) {
                
                // vitals
                if ([identifier isEqualToString:@"org.mitre.hreader.vitals"]) {
                    NSDictionary *vitals = [patient vitalSignsGroupedByDescription];
                    [vitals enumerateKeysAndObjectsUsingBlock:^(NSString *type, NSArray *entries, BOOL *stop) {
                        HRVitalView *view = [HRVitalView tileWithPatient:patient userInfo:dictionary];
                        if ([type isEqualToString:@"BMI"]) {
                            view.vital = [[HRBMI alloc] initWithEntries:entries];
                        }
                        else  {
                            view.vital = [[HRVital alloc] initWithEntries:entries];
                        }
                        [views addObject:view];
                    }];
                }
                
                // others
                else {
                    Class c = NSClassFromString([dictionary objectForKey:@"class_name"]);
                    [views addObject:[c tileWithPatient:patient userInfo:dictionary]];
                }
                
            }
            else { NSLog(@"Unable to find applet with identifier %@", identifier); }
        }];
        
        // save and reload
        __gridViews = views;
        [self.gridView reloadData];
        
    }
    
    {
        
        /*
        
        // upcoming events
        
        
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
        
        */
        
        

        
        
        
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
    
    [self setRecentConditionsDateLabel:nil];
    [self setRecentConditionsLabel:nil];
    [self setChronicConditionsLabel:nil];
    [self setUpcomingEventsLabel:nil];
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

#pragma mark - private

- (NSString *)formattedDate:(double)interval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    return [date mediumStyleDate];
}

@end
