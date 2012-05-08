//
//  HRSparkLineLine.m
//  CorePlotExample
//
//  Created by Marshall Huss on 4/30/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRSparkLineLine.h"

#if !__has_feature(objc_arc)
#error This class requires ARC
#endif

@implementation HRSparkLineLine

@synthesize points = __points;
@synthesize lineColor = __lineColor;
@synthesize outOfRangeDotColor = __outOfRangeDotColor;
@synthesize weight = __weight;
@synthesize range = __range;
@synthesize lineJoin = __lineJoin;
@synthesize lineCap = __lineCap;
@synthesize rangeColor = __rangeColor;

#pragma mark - class methods

+ (HRSparkLineLine *)lineWithPoints:(HRSparkLinePoint *)point, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *array = [NSMutableArray array];
    if (point) {
        [array addObject:point];
        id object;
        va_list args;
        va_start(args, point);
        while ((object = va_arg(args, id))) {
            [array addObject:object];
        }
        va_end(args);
    }
    HRSparkLineLine *line = [[HRSparkLineLine alloc] init];
    line.points = array;
    return line;
}

#pragma mark - instance methods

- (id)init {
    self = [super init];
    if (self) {
        __lineColor = [UIColor blackColor];
        __weight = 4.0;
        __outOfRangeDotColor = [UIColor redColor];
        __lineCap = kCGLineCapRound;
        __lineJoin = kCGLineJoinRound;
        __range = HRZeroRange;
        __rangeColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    }
    return self;
}

@end
