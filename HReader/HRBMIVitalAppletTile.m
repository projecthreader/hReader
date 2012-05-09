//
//  HRBMIVitalAppletTile.m
//  HReader
//
//  Created by Marshall Huss on 4/16/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRBMIVitalAppletTile.h"
#import "HRKeyValueTableViewController.h"
#import "HRSparkLineView.h"
#import "HRMEntry.h"


#import "NSDate+FormattedDate.h"
#import "NSArray+Collect.h"

@interface HRBMIVitalAppletTile () {
@private
    NSArray * __strong __entries;
}

- (double)normalLow;
- (double)normalHigh;
- (BOOL)isValueNormal:(double)value;

@end

@implementation HRBMIVitalAppletTile

- (void)tileDidLoad {
    [super tileDidLoad];
    
    // save points
    __entries = [self.patient vitalSignsWithType:@"BMI"];
    HRMEntry *latest = [__entries lastObject];
    
    // set labels
    self.titleLabel.text = @"BMI";
    self.leftTitleLabel.text = @"RECENT RESULT:";
    float latestValue = [[latest valueForKeyPath:@"value.scalar"] floatValue];
    self.leftValueLabel.text = [NSString stringWithFormat:@"%0.1f", latestValue];
    self.leftValueLabel.adjustsFontSizeToFitWidth = YES;
    self.leftValueLabel.textColor = ([self isValueNormal:latestValue]) ? [UIColor blackColor] : [HRConfig redColor];
    self.middleTitleLabel.text = @"DATE:";
    self.middleValueLabel.text = [latest.date shortStyleDate];
    self.middleValueLabel.adjustsFontSizeToFitWidth = YES;
    self.rightValueLabel.text = [NSString stringWithFormat:@"%0.0f-%0.0f", [self normalLow], [self normalHigh]];
    self.rightValueLabel.adjustsFontSizeToFitWidth = YES;
    
    // sparkline    
    HRSparkLineRange range = HRMakeRange([self normalLow], [self normalHigh] - [self normalLow]);
    HRSparkLineLine *line = [[HRSparkLineLine alloc] init];
    line.outOfRangeDotColor = [HRConfig redColor];
    line.weight = 4.0;
    line.points = [self dataForSparkLineView];
    line.range = range;
    self.sparkLineView.lines = [NSArray arrayWithObject:line];

    // display normal value
    float val = [[latest valueForKeyPath:@"value.scalar"] floatValue];
    self.rightValueLabel.textColor = ([self isValueNormal:val]) ? [UIColor blackColor] : [HRConfig redColor];
    
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

- (NSString *)titleForKeyValueTable {
    return self.titleLabel.text;
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
    return 18.0;
}

- (double)normalHigh {
    return 25.0;
}

- (BOOL)isValueNormal:(double)value {
    return (value >= [self normalLow] && value <= [self normalHigh]);
}

@end
