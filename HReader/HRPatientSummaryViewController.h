//
//  HRPatientSummarySplitViewController.h
//  HReader
//
//  Created by Marshall Huss on 11/30/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HRGridTableView.h"

@interface HRPatientSummaryViewController : UIViewController <HRGridTableViewDelegate>

// container views
@property (nonatomic, strong) IBOutlet HRGridTableView *gridView;
@property (retain, nonatomic) IBOutlet UIView *headerView;

// key labels
@property (retain, nonatomic) IBOutlet UILabel *patientNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *dateOfBirthLabel;
@property (retain, nonatomic) IBOutlet UILabel *dateOfBirthTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *recentConditionsDateLabel;
@property (retain, nonatomic) IBOutlet UILabel *recentConditionsLabel;
@property (retain, nonatomic) IBOutlet UILabel *chronicConditionsLabel;
@property (retain, nonatomic) IBOutlet UILabel *allergiesLabel;
@property (retain, nonatomic) IBOutlet UILabel *followUpAppointmentLabel;
@property (retain, nonatomic) IBOutlet UILabel *medicationRefillLabel;
@property (retain, nonatomic) IBOutlet UILabel *upcomingEventsLabel;
@property (retain, nonatomic) IBOutlet UILabel *planOfCareLabel;


// collection of all labels
@property (retain, nonatomic) IBOutletCollection(UILabel) NSArray *labels;

// medication labels
@property (retain, nonatomic) IBOutletCollection(UILabel) NSArray *medicationNameLabels;
@property (retain, nonatomic) IBOutletCollection(UILabel) NSArray *medicationDosageLabels;

// vital view collection
@property (retain, nonatomic) IBOutletCollection(UIView) NSArray *vitalViews;








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
