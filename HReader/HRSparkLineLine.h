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

@interface HRSparkLineLine : NSObject// <UIAppearance>

@property (nonatomic, copy) NSArray *points;
@property (nonatomic, strong) UIColor *lineColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *outOfRangeDotColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat weight UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) HRSparkLineRange range;
@property (nonatomic, assign) CGLineJoin lineJoin UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGLineCap lineCap UI_APPEARANCE_SELECTOR;

+ (HRSparkLineLine *)lineWithPoints:(HRSparkLinePoint *)point, ... NS_REQUIRES_NIL_TERMINATION;

@end
