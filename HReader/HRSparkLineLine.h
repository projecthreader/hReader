//
//  HRSparkLineLine.h
//  CorePlotExample
//
//  Created by Marshall Huss on 4/30/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HRSparkLineRange.h"

@class HRSparkLinePoint;

@interface HRSparkLineLine : NSObject

@property (nonatomic, copy) NSArray *points;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIColor *outOfRangeDotColor;
@property (nonatomic, assign) CGFloat weight;
@property (nonatomic, assign) HRSparkLineRange range;
@property (nonatomic, strong) UIColor *rangeColor;
@property (nonatomic, assign) CGLineJoin lineJoin;
@property (nonatomic, assign) CGLineCap lineCap;

+ (HRSparkLineLine *)lineWithPoints:(HRSparkLinePoint *)point, ... NS_REQUIRES_NIL_TERMINATION;

@end
