//
//  HRBloodPressueAppletTile.h
//  HReader
//
//  Created by Marshall Huss on 4/16/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRAppletTile.h"

@class HRSparkLineView;

@interface HRBloodPressureAppletTile : HRAppletTile

@property (retain, nonatomic) IBOutlet UILabel *resultLabel;
@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UILabel *normalLabel;
@property (retain, nonatomic) IBOutlet HRSparkLineView *sparkLineView;

@end
