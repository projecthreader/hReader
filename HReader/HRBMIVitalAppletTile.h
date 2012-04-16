//
//  HRBMIVitalAppletTile.h
//  HReader
//
//  Created by Marshall Huss on 4/16/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRAppletTile.h"

@class HRSparkLineView;

@interface HRBMIVitalAppletTile : HRAppletTile

@property (strong, nonatomic) IBOutlet UILabel *resultLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UILabel *normalLabel;

@property (strong, nonatomic) IBOutlet HRSparkLineView *sparkLineView;


@end
