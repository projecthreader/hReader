//
//  HROxygenSaturationAppletTile.m
//  HReader
//
//  Created by Caleb Davenport on 5/4/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HROxygenSaturationAppletTile.h"

#import "HRMEntry.h"

#import "NSDate+FormattedDate.h"

#if !__has_feature(objc_arc)
#error This class requires ARC
#endif

@interface HROxygenSaturationAppletTile ()  {
@private
    NSArray * __strong __entries;
}

- (double)normalLow;
- (double)normalHigh;
- (BOOL)isValueNormal:(double)value;

@end

@implementation HROxygenSaturationAppletTile

- (void)tileDidLoad {
    [super tileDidLoad];
    
    // save points
    __entries = [self.patient vitalSignsWithType:@"Oxygen Saturation"];
    HRMEntry *latest = [__entries lastObject];
    
    // set labels
    self.titleLabel.text = @"Oxygen Saturation";
    self.leftTitleLabel.text = @"RECENT RESULT:";
    float latestValue = [[latest valueForKeyPath:@"value.scalar"] floatValue];
    self.leftValueLabel.text = [NSString stringWithFormat:@"%0.1f", latestValue];
    self.leftValueLabel.adjustsFontSizeToFitWidth = YES;
    self.leftValueLabel.textColor = ([self isValueNormal:latestValue]) ? [UIColor blackColor] : [HRConfig redColor];
    self.middleTitleLabel.text = @"DATE:";
    
    self.middleValueLabel.text = [latest.date shortStyleDate];
    self.middleValueLabel.adjustsFontSizeToFitWidth = YES;
    self.rightValueLabel.text = [NSString stringWithFormat:@"%d%%-%d%%",
                                 (NSInteger)[self normalLow],
                                 (NSInteger)[self normalHigh]];
    self.rightValueLabel.adjustsFontSizeToFitWidth = YES;
    
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
        double value = [[entry.value objectForKey:@"scalar"] doubleValue];
        BOOL isNormal = [self isValueNormal:value];
        UIColor *color = isNormal ? [UIColor blackColor] : [HRConfig redColor];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"%0.1f", value], @"detail",
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

- (double)normalLow {
    return 95.0;
}

- (double)normalHigh {
    return 100.0;
}

- (BOOL)isValueNormal:(double)value {
    return (value >= [self normalLow] && value <= [self normalHigh]);
}

@end
