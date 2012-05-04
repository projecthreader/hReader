//
//  HRVitalView.h
//  HReader
//
//  Created by Marshall Huss on 2/8/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HRAppletTile.h"
#import "HRSparkLineView.h"

@interface HRVitalAppletTile : HRAppletTile

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *leftTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *middleTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *rightTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *leftValueLabel;
@property (nonatomic, strong) IBOutlet UILabel *middleValueLabel;
@property (nonatomic, strong) IBOutlet UILabel *rightValueLabel;
@property (nonatomic, strong) IBOutlet HRSparkLineView *sparkLineView;

- (NSArray *)dataForKeyValueTable;
- (NSString *)titleForKeyValueTable;
- (NSArray *)dataForSparkLineView;

@end
