//
//  HRBloodPressueAppletTile.m
//  HReader
//
//  Created by Marshall Huss on 4/16/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRBloodPressureAppletTile.h"

#import "HRMEntry.h"
#import "HRMPatient.h"

#import "HRSparkLineView.h"
#import "HRKeyValueTableViewController.h"

#import "NSDate+FormattedDate.h"
#import "NSArray+Collect.h"

@implementation HRBloodPressureAppletTile {
    NSArray *_systolicDataPoints;
    NSArray *_diastolicDataPoints;
}

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
    NSMutableArray *points = [NSMutableArray arrayWithCapacity:[_systolicDataPoints count]];
    [_systolicDataPoints enumerateObjectsUsingBlock:^(HRMEntry *entry, NSUInteger index, BOOL *stop) {
        double systolicValue = [[entry.value objectForKey:@"scalar"] doubleValue];
        double diastolicValue = 0;
        if (index < [_diastolicDataPoints count]) {
            HRMEntry *diastolicEntry = [_diastolicDataPoints objectAtIndex:index];
            diastolicValue = [[diastolicEntry.value objectForKey:@"scalar"] doubleValue];
        }
        BOOL isNormal = [self isSystolicValueNormal:systolicValue];
        UIColor *color = (isNormal ? [UIColor blackColor] : [UIColor hr_redColor]);
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
    _systolicDataPoints = [self.patient vitalSignsWithType:@"systolic blood pressure"];
    _diastolicDataPoints = [self.patient vitalSignsWithType:@"diastolic blood pressure"];
    HRMEntry *lastestSystolic = [_systolicDataPoints lastObject];
    HRMEntry *lastestDiastolic = [_diastolicDataPoints lastObject];
    
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
    systolicLine.outOfRangeDotColor = [UIColor hr_redColor];
    systolicLine.weight = 4.0;
    systolicLine.points = [self sparklinePointsForEntries:_systolicDataPoints];
    systolicLine.range = HRMakeRange([self normalSystolicLow], [self normalSystolicHigh] - [self normalSystolicLow]);
    
    // diastolic range
    HRSparkLineLine *diastolicLine = [[HRSparkLineLine alloc] init];
    diastolicLine.outOfRangeDotColor = [UIColor hr_redColor];
    diastolicLine.weight = 4.0;
    diastolicLine.points = [self sparklinePointsForEntries:_diastolicDataPoints];
    diastolicLine.range = HRMakeRange([self normalDiastolicLow], [self normalDiastolicHigh] - [self normalDiastolicLow]);
    
    // sparkline
    self.sparkLineView.lines = [NSArray arrayWithObjects:systolicLine, diastolicLine, nil];
    
    // display normal value
    float systolicValue = [[lastestSystolic valueForKeyPath:@"value.scalar"] floatValue];
    if ([self isSystolicValueNormal:systolicValue]) { self.leftValueLabel.textColor = [UIColor blackColor]; }
    else { self.leftValueLabel.textColor = [UIColor hr_redColor]; }
    
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
