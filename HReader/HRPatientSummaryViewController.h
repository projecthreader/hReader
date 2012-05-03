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
@property (strong, nonatomic) IBOutlet HRGridTableView *gridView;
@property (retain, nonatomic) IBOutlet UIView *headerView;

// key labels
@property (strong, nonatomic) IBOutlet UILabel *patientNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateOfBirthLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateOfBirthTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *allergiesLabel;
@property (strong, nonatomic) IBOutlet UIImageView *patientImageView;

// conditions
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *conditionNameLabels;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *conditionDateLabels;

// events
@property (strong, nonatomic) IBOutlet UILabel *followUpAppointmentNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *followUpAppointmentDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *planOfCareLabel;
@property (strong, nonatomic) IBOutlet UILabel *medicationRefillNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *medicationRefillDateLabel;










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
