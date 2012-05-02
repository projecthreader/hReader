//
//  HRSparkLineLine.m
//  CorePlotExample
//
//  Created by Marshall Huss on 4/30/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRSparkLineLine.h"

@implementation HRSparkLineLine

@synthesize points = __points;
@synthesize lineColor = __lineColor;
@synthesize outOfRangeDotColor = __outOfRangeDotColor;
@synthesize weight = __weight;
@synthesize range = __range;
@synthesize lineJoin = __lineJoin;
@synthesize lineCap = __lineCap;

#pragma mark - class methods

//+ (id)appearance {
//    static dispatch_once_t token;
//    static HRSparkLineLine *line = nil;
//    dispatch_once(&token, ^{
//        line = [[HRSparkLineLine alloc] init];
//        line.lineColor = [UIColor blackColor];
//        line.weight = 4.0;
//        line.outOfRangeDotColor = [UIColor redColor];
//        line.lineCap = kCGLineCapRound;
//        line.lineJoin = kCGLineJoinRound;
//    });
//    return line;
//}
//
//+ (id)appearanceWhenContainedIn:(Class <UIAppearanceContainer>)ContainerClass, ... {
//    static dispatch_once_t token;
//    static HRSparkLineLine *line = nil;
//    dispatch_once(&token, ^{
//        line = [[HRSparkLineLine alloc] init];
//    });
//    return line;
//    return nil;
//}

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
//        HRSparkLineLine *line = [HRSparkLineLine appearance];
//        __weight = line.weight;
//        __lineColor = line.lineColor;
//        __outOfRangeDotColor = line.outOfRangeDotColor;
//        __lineJoin  = line.lineJoin;
//        __lineCap = line.lineCap;
        __lineColor = [UIColor blackColor];
        __weight = 4.0;
        __outOfRangeDotColor = [UIColor redColor];
        __lineCap = kCGLineCapRound;
        __lineJoin = kCGLineJoinRound;
        __range = HRZeroRange;
    }
    return self;
}

@end
