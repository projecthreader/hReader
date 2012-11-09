//
//  HRRespiratoryRateAppletTile.m
//  HReader
//
//  Created by Caleb Davenport on 5/4/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRRespiratoryRateAppletTile.h"
#import "HRMEntry.h"
#import "HRMPatient.h"
#import "HRSparkLineView.h"

@implementation HRRespiratoryRateAppletTile {
    NSArray *_entries;
}

- (void)tileDidLoad {
    [super tileDidLoad];
    
    // save points
    _entries = [self.patient vitalSignsWithType:@"Respiration"];
    HRMEntry *latest = [_entries lastObject];
    
    // set labels
    NSInteger latestValue = [[latest valueForKeyPath:@"value.scalar"] integerValue];
    self.leftValueLabel.text = [NSString stringWithFormat:@"%lu", (long)latestValue];
    self.leftValueLabel.textColor = ([self isValueNormal:latestValue] ? [UIColor blackColor] : [UIColor hr_redColor]);
    self.middleValueLabel.text = [latest.date hr_shortStyleDate];
    self.rightValueLabel.text = [NSString stringWithFormat:@"%lu-%lu",
                                 (unsigned long)[self normalLow],
                                 (unsigned long)[self normalHigh]];
    
    // sparkline    
    HRSparkLineRange range = HRMakeRange([self normalLow], [self normalHigh] - [self normalLow]);
    HRSparkLineLine *line = [[HRSparkLineLine alloc] init];
    line.points = [self dataForSparkLineView];
    line.range = range;
    self.sparkLineView.lines = [NSArray arrayWithObject:line];
    
}

- (NSArray *)dataForKeyValueTable {
    NSMutableArray *entries = [NSMutableArray arrayWithCapacity:[_entries count]];
    [_entries enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(HRMEntry *entry, NSUInteger index, BOOL *stop) {
        NSInteger value = [[entry.value objectForKey:@"scalar"] integerValue];
        BOOL normal = [self isValueNormal:value];
        UIColor *color = (normal ? [UIColor blackColor] : [UIColor hr_redColor]);
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"%lu", (unsigned long)value], @"detail",
                                    [entry.date hr_mediumStyleDate], @"title",
                                    color, @"detail_color",
                                    nil];
        [entries addObject:dictionary];
    }];
    return [entries copy];
}

- (NSArray *)dataForSparkLineView {
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:[_entries count]];
    [_entries enumerateObjectsUsingBlock:^(HRMEntry *entry, NSUInteger index, BOOL *stop) {
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
