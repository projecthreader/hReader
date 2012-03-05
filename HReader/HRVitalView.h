//
//  HRVitalView.h
//  HReader
//
//  Created by Marshall Huss on 2/8/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HRVital;
@class ASBSparkLineView;

@interface HRVitalView : UIView

@property (retain, nonatomic) IBOutlet UILabel *leftLabel;
@property (retain, nonatomic) IBOutlet UILabel *rightLabel;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *resultLabel;
@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UILabel *normalLabel;
@property (retain, nonatomic) IBOutlet UILabel *unitsLabel;
@property (retain, nonatomic) IBOutlet ASBSparkLineView *sparkLineView;

- (void)showVital:(HRVital *)vital;

@end
