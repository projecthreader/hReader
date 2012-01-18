//
//  HRPatientSummarySplitViewController.h
//  HReader
//
//  Created by Marshall Huss on 11/30/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HRPatientSwipeViewController;

@interface HRPatientSummaryViewController : UIViewController <UIScrollViewDelegate>

@property (retain, nonatomic) IBOutlet UIView *patientHeaderView;
@property (retain, nonatomic) IBOutlet UIScrollView *patientScrollView;
@property (retain, nonatomic) IBOutlet UIView *patientSummaryView;
@property (retain, nonatomic) IBOutlet UILabel *patientName;

@property (retain, nonatomic) IBOutlet UILabel *dobLabel;

@property (retain, nonatomic) NSArray *labelsArray;

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

@property (retain, nonatomic) IBOutlet UILabel *currentMedicationsLabel;
@property (retain, nonatomic) IBOutlet UILabel *currentMedicationsDosageLabel;

@property (retain, nonatomic) IBOutlet UILabel *functionalStatusDateLabel;
@property (retain, nonatomic) IBOutlet UILabel *functionalStatusTypeLabel;
@property (retain, nonatomic) IBOutlet UILabel *functionalStatusProblemLabel;
@property (retain, nonatomic) IBOutlet UILabel *functionalStatusStatusLabel;

@property (retain, nonatomic) IBOutlet UILabel *heightTitleLabel;

@property (retain, nonatomic) IBOutlet UILabel *heightLabel;
@property (retain, nonatomic) IBOutlet UILabel *heightDateLabel;
@property (retain, nonatomic) IBOutlet UILabel *heightNormalLabel;

@property (retain, nonatomic) IBOutlet UILabel *weightLabel;
@property (retain, nonatomic) IBOutlet UILabel *weightDateLabel;
@property (retain, nonatomic) IBOutlet UILabel *weightNormalLabel;

@property (retain, nonatomic) IBOutlet UILabel *bmiLabel;
@property (retain, nonatomic) IBOutlet UILabel *bmiDateLabel;
@property (retain, nonatomic) IBOutlet UILabel *bmiNormalLabel;

@property (retain, nonatomic) IBOutlet UILabel *pulseLabel;
@property (retain, nonatomic) IBOutlet UILabel *pulseDateLabel;
@property (retain, nonatomic) IBOutlet UILabel *pulseNormalLabel;

@property (retain, nonatomic) IBOutlet UILabel *advanceDirectivesLabel;

@property (retain, nonatomic) IBOutlet UILabel *diagnosisLabel;
@property (retain, nonatomic) IBOutlet UILabel *diagnosisDateLabel;
@property (retain, nonatomic) IBOutlet UIImageView *heightImageView;
@property (retain, nonatomic) IBOutlet UIImageView *weightImageView;
@property (retain, nonatomic) IBOutlet UIImageView *bmiImageView;
@property (retain, nonatomic) IBOutlet UIImageView *pulseImageView;


@end
