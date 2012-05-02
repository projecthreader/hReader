//
//  HRSparkLinePoint.m
//  CorePlotExample
//
//  Created by Marshall Huss on 4/30/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRSparkLinePoint.h"

@implementation HRSparkLinePoint

@synthesize x = __x;
@synthesize y =__y;

+ (HRSparkLinePoint *)pointWithX:(CGFloat)x y:(CGFloat)y {
    HRSparkLinePoint *point = [[HRSparkLinePoint alloc] init];
    point.x = x;
    point.y = y;
    return point;
}

@end
