//
//  HRSparkLine.h
//  CorePlotExample
//
//  Created by Marshall Huss on 4/30/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HRSparkLineLine.h"
#import "HRSparkLinePoint.h"
#import "HRSparklineRange.h"

@interface HRSparkLineView : UIView <UIAppearance>

@property (copy, nonatomic) NSArray *lines;
@property (assign, nonatomic) HRSparkLineRange visibleRange;
@property (strong, nonatomic) UIColor *visibleRangeColor UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) UIEdgeInsets edgeInsets;

@end
