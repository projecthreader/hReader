//
//  HRPatientSummarySplitViewController.h
//  HReader
//
//  Created by Marshall Huss on 11/30/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "HRContentViewController.h"
#import "HRGridTableView.h"

@interface HRPatientSummaryViewController : HRContentViewController <HRGridTableViewDelegate, HRGridTableViewDataSource>

// container views
@property (nonatomic, weak) IBOutlet HRGridTableView *gridView;

// key labels
@property (nonatomic, weak) IBOutlet UILabel *dateOfBirthLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateOfBirthTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *allergiesLabel;

// conditions
@property (nonatomic, weak) IBOutlet UIView *conditionsContainerView;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *conditionNameLabels;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *conditionDateLabels;

// events
@property (nonatomic, weak) IBOutlet UIView *eventsContainerView;
@property (nonatomic, weak) IBOutlet UILabel *followUpAppointmentNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *followUpAppointmentDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *planOfCareLabel;
@property (nonatomic, weak) IBOutlet UILabel *medicationRefillNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *medicationRefillDateLabel;










@property (nonatomic, weak) IBOutlet UILabel *functionalStatusDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *functionalStatusTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *functionalStatusProblemLabel;
@property (nonatomic, weak) IBOutlet UILabel *functionalStatusStatusLabel;

@property (nonatomic, weak) IBOutlet UILabel *advanceDirectivesLabel;

@property (nonatomic, weak) IBOutlet UILabel *diagnosisLabel;
@property (nonatomic, weak) IBOutlet UILabel *diagnosisDateLabel;

@end
