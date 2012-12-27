//
//  HRVitalView.h
//  HReader
//
//  Created by Marshall Huss on 2/8/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRAppletTile.h"

@class HRMPatient;
@class HRSparkLineView;

@interface HRVitalAppletTile : HRAppletTile

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *leftTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *middleTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *rightTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *leftValueLabel;
@property (nonatomic, strong) IBOutlet UILabel *middleValueLabel;
@property (nonatomic, strong) IBOutlet UILabel *rightValueLabel;
@property (nonatomic, strong) IBOutlet HRSparkLineView *sparkLineView;
@property (nonatomic, readonly) HRMPatient *patient;

- (NSArray *)dataForKeyValueTable;
- (NSString *)titleForKeyValueTable;
- (NSArray *)dataForSparkLineView;

@end
