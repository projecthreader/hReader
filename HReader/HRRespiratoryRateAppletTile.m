//
//  HRRespiratoryRateAppletTile.m
//  HReader
//
//  Created by Caleb Davenport on 5/4/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRRespiratoryRateAppletTile.h"

#import "HRMEntry.h"

#import "NSDate+FormattedDate.h"

@interface HRRespiratoryRateAppletTile ()  {
@private
    NSArray * __strong __entries;
}

- (NSInteger)normalLow;
- (NSInteger)normalHigh;
- (BOOL)isValueNormal:(NSInteger)value;

@end

@implementation HRRespiratoryRateAppletTile

- (void)tileDidLoad {
    [super tileDidLoad];
    
    // save points
    __entries = [self.patient vitalSignsWithType:@"Respiration"];
    HRMEntry *latest = [__entries lastObject];
    
    // set labels
    NSInteger latestValue = [[latest valueForKeyPath:@"value.scalar"] integerValue];
    self.leftValueLabel.text = [NSString stringWithFormat:@"%lu", (long)latestValue];
    self.leftValueLabel.textColor = [self isValueNormal:latestValue] ? [UIColor blackColor] : [HRConfig redColor];
    self.middleValueLabel.text = [latest.date shortStyleDate];
    self.rightValueLabel.text = [NSString stringWithFormat:@"%lu-%lu",
                                 [self normalLow],
                                 [self normalHigh]];
    
    // sparkline    
    HRSparkLineRange range = HRMakeRange([self normalLow], [self normalHigh] - [self normalLow]);
    HRSparkLineLine *line = [[HRSparkLineLine alloc] init];
    line.points = [self dataForSparkLineView];
    line.range = range;
    self.sparkLineView.lines = [NSArray arrayWithObject:line];
    
}

- (NSArray *)dataForKeyValueTable {
    NSMutableArray *entries = [NSMutableArray arrayWithCapacity:[__entries count]];
    [__entries enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(HRMEntry *entry, NSUInteger index, BOOL *stop) {
        NSInteger value = [[entry.value objectForKey:@"scalar"] integerValue];
        BOOL normal = [self isValueNormal:value];
        UIColor *color = normal ? [UIColor blackColor] : [HRConfig redColor];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"%lu", value], @"detail",
                                    [entry.date mediumStyleDate], @"title",
                                    color, @"detail_color",
                                    nil];
        [entries addObject:dictionary];
    }];
    return [entries copy];
}

- (NSArray *)dataForSparkLineView {
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:[__entries count]];
    [__entries enumerateObjectsUsingBlock:^(HRMEntry *entry, NSUInteger index, BOOL *stop) {
        NSTimeInterval timeInterval = [entry.date timeIntervalSince1970];
        NSInteger value = [[entry.value objectForKey:@"scalar"] integerValue];
        HRSparkLinePoint *point = [HRSparkLinePoint pointWithX:timeInterval y:value];
        [points addObject:point];
    }];
    
    return points;
}

- (NSInteger)normalLow {
    return 12;
}

- (NSInteger)normalHigh {
    return 20;
}

- (BOOL)isValueNormal:(NSInteger)value {
    return (value >= [self normalLow] && value <= [self normalHigh]);
}

@end
