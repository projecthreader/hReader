//
//  HRPatientSummarySplitViewController.h
//  HReader
//
//  Created by Marshall Huss on 11/30/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPatientSummaryViewController : UIViewController <UIPopoverControllerDelegate, UIGestureRecognizerDelegate>

// container and utility views
@property (retain, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) IBOutlet UIView *footerShadowView;

// collection of all labels
@property (retain, nonatomic) IBOutletCollection(UILabel) NSArray *labels;

// medication labels
@property (retain, nonatomic) IBOutletCollection(UILabel) NSArray *medicationNameLabels;
@property (retain, nonatomic) IBOutletCollection(UILabel) NSArray *medicationDosageLabels;

// vital view collection
@property (retain, nonatomic) IBOutletCollection(UIView) NSArray *vitalViews;

@property (retain, nonatomic) IBOutlet UILabel *patientName;

@property (retain, nonatomic) IBOutlet UILabel *dobLabel;

@property (retain, nonatomic) IBOutlet UILabel *allergiesLabel;
@property (retain, nonatomic) IBOutlet UILabel *recentConditionsDateLabel;
@property (retain, nonatomic) IBOutlet UILabel *recentConditionsLabel;
@property (retain, nonatomic) IBOutlet UILabel *chronicConditionsLabel;
@property (retain, nonatomic) IBOutlet UILabel *upcomingEventsLabel;
@property (retain, nonatomic) IBOutlet UILabel *planOfCareLabel;
@property (retain, nonatomic) IBOutlet UILabel *followUpAppointmentLabel;
@property (retain, nonatomic) IBOutlet UILabel *medicationRefillLabel;

@property (retain, nonatomic) IBOutlet UILabel *recentEncountersDateLabel;
@property (retain, nonatomic) IBOutlet UILabel *recentEncountersTypeLabel;
@property (retain, nonatomic) IBOutlet UILabel *recentEncountersDescriptionLabel;

@property (retain, nonatomic) IBOutlet UILabel *immunizationsUpToDateLabel;

@property (retain, nonatomic) IBOutlet UILabel *functionalStatusDateLabel;
@property (retain, nonatomic) IBOutlet UILabel *functionalStatusTypeLabel;
@property (retain, nonatomic) IBOutlet UILabel *functionalStatusProblemLabel;
@property (retain, nonatomic) IBOutlet UILabel *functionalStatusStatusLabel;

@property (retain, nonatomic) IBOutlet UILabel *pulseLabel;
@property (retain, nonatomic) IBOutlet UILabel *pulseDateLabel;
@property (retain, nonatomic) IBOutlet UILabel *pulseNormalLabel;

@property (retain, nonatomic) IBOutlet UILabel *advanceDirectivesLabel;

@property (retain, nonatomic) IBOutlet UILabel *diagnosisLabel;
@property (retain, nonatomic) IBOutlet UILabel *diagnosisDateLabel;

@property (retain, nonatomic) IBOutlet UIImageView *pulseImageView;

@end
