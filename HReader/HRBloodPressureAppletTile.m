//
//  HRBloodPressueAppletTile.m
//  HReader
//
//  Created by Marshall Huss on 4/16/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRBloodPressureAppletTile.h"
#import "HRMEntry.h"
#import "HRSparkLineView.h"
#import "HRKeyValueTableViewController.h"

#import "NSDate+FormattedDate.h"
#import "NSArray+Collect.h"

@interface HRBloodPressureAppletTile () {
@private
    NSArray * __strong __systolicDataPoints;
    NSArray * __strong __diastolicDataPoints;
}

- (double)normalSystolicLow;
- (double)normalSystolicHigh;
- (double)normalDiastolicLow;
- (double)normalDiastolicHigh;
- (BOOL)isSystolicValueNormal:(double)value;
- (BOOL)isDiastolicValueNormal:(double)value;
- (NSArray *)sparklinePointsForEntries:(NSArray *)entries;

@end

@implementation HRBloodPressureAppletTile

- (NSArray *)sparklinePointsForEntries:(NSArray *)entries {
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:[entries count]];
    [entries enumerateObjectsUsingBlock:^(HRMEntry *entry, NSUInteger index, BOOL *stop) {
        NSTimeInterval timeInterval = [entry.date timeIntervalSince1970];
        NSString *scalarString = [entry.value objectForKey:@"scalar"];
        CGFloat value = 0.0;
        if ([scalarString isKindOfClass:[NSString class]]) {
            value = [scalarString floatValue];
        }
        HRSparkLinePoint *point = [HRSparkLinePoint pointWithX:timeInterval y:value];
        [points addObject:point];
    }];
    return points;
}

- (NSArray *)dataForKeyValueTable {
    NSMutableArray *points = [NSMutableArray arrayWithCapacity:[__systolicDataPoints count]];
    [__systolicDataPoints enumerateObjectsUsingBlock:^(HRMEntry *entry, NSUInteger index, BOOL *stop) {
        double systolicValue = [[entry.value objectForKey:@"scalar"] doubleValue];
        double diastolicValue = 0;
        if (index < [__diastolicDataPoints count]) {
            HRMEntry *diastolicEntry = [__diastolicDataPoints objectAtIndex:index];
            diastolicValue = [[diastolicEntry.value objectForKey:@"scalar"] doubleValue];
        }
        BOOL isNormal = [self isSystolicValueNormal:systolicValue];
        UIColor *color = isNormal ? [UIColor blackColor] : [HRConfig redColor];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"%.0f/%.0f", systolicValue, diastolicValue], @"detail",
                                    [entry.date mediumStyleDate], @"title",
                                    color, @"detail_color",
                                    nil];
        [points addObject:dictionary];
    }];
    return points;
}

- (void)tileDidLoad {
    [super tileDidLoad];
    
    // save points
    __systolicDataPoints = [self.patient vitalSignsWithType:@"systolic blood pressure"];
    __diastolicDataPoints = [self.patient vitalSignsWithType:@"diastolic blood pressure"];
    HRMEntry *lastestSystolic = [__systolicDataPoints lastObject];
    HRMEntry *lastestDiastolic = [__diastolicDataPoints lastObject];
    
    // set labels
    double lastestSystolicValue = [[lastestSystolic valueForKeyPath:@"value.scalar"] doubleValue];
    double lastestDiastolicValue = [[lastestDiastolic valueForKeyPath:@"value.scalar"] doubleValue];
    self.middleValueLabel.text = [lastestSystolic.date shortStyleDate];
    self.middleValueLabel.adjustsFontSizeToFitWidth = YES;
    self.leftValueLabel.text = [NSString stringWithFormat:@"%.0f/%.0f", lastestSystolicValue, lastestDiastolicValue];
    self.rightValueLabel.text = [NSString stringWithFormat:
                                 @"%.0f-%.0f/%.0f-%.0f",
                                 [self normalSystolicLow],
                                 [self normalSystolicHigh],
                                 [self normalDiastolicLow],
                                 [self normalDiastolicHigh]];
    
    // systolic line
    HRSparkLineLine *systolicLine = [[HRSparkLineLine alloc] init];
    systolicLine.outOfRangeDotColor = [HRConfig redColor];
    systolicLine.weight = 4.0;
    systolicLine.points = [self sparklinePointsForEntries:__systolicDataPoints];
    systolicLine.range = HRMakeRange([self normalSystolicLow], [self normalSystolicHigh] - [self normalSystolicLow]);
    
    // diastolic range
    HRSparkLineLine *diastolicLine = [[HRSparkLineLine alloc] init];
    diastolicLine.outOfRangeDotColor = [HRConfig redColor];
    diastolicLine.weight = 4.0;
    diastolicLine.points = [self sparklinePointsForEntries:__diastolicDataPoints];
    diastolicLine.range = HRMakeRange([self normalDiastolicLow], [self normalDiastolicHigh] - [self normalDiastolicLow]);
    
    // sparkline
    self.sparkLineView.lines = [NSArray arrayWithObjects:systolicLine, diastolicLine, nil];
    
    // display normal value
    float systolicValue = [[lastestSystolic valueForKeyPath:@"value.scalar"] floatValue];
    if ([self isSystolicValueNormal:systolicValue]) { self.leftValueLabel.textColor = [UIColor blackColor]; }
    else { self.leftValueLabel.textColor = [HRConfig redColor]; }
    
}

- (double)normalSystolicLow {
    return 90.0;
}

- (double)normalSystolicHigh {
    return 120.0;
}

- (double)normalDiastolicLow {
    return 60.0;
}

- (double)normalDiastolicHigh {
    return 80.0;
}

- (BOOL)isSystolicValueNormal:(double)value {
    return (value >= [self normalSystolicLow] && value <= [self normalSystolicHigh]);
}

- (BOOL)isDiastolicValueNormal:(double)value {
    return (value >= [self normalDiastolicLow] && value <= [self normalDiastolicHigh]);
}

@end
