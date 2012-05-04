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

@interface HRSparkLineView : UIView

@property (nonatomic, copy) NSArray *lines;
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

@end
