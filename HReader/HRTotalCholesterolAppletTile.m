//
//  HRTotalCholesterolAppletTile.m
//  HReader
//
//  Created by Caleb Davenport on 11/9/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRTotalCholesterolAppletTile.h"
#import "HRMPatient.h"
#import "HRMEntry.h"
#import "HRSparkLineView.h"

@implementation HRTotalCholesterolAppletTile {
    NSArray *_entries;
}

- (void)tileDidLoad {
    [super tileDidLoad];
    
    // save points
    _entries = [self.patient totalCholesterol];
    NSLog(@"%@", [[NSString alloc] initWithData:[self.patient timelineJSONPayloadWithPredicate:nil error:nil] encoding:NSUTF8StringEncoding]);
    HRMEntry *latest = [_entries lastObject];
    
    // get age
    NSInteger age = [self ageInYears];
    
    self.rightValueLabel.text = [NSString stringWithFormat:
                                 @"%0.1f-%0.1f",
                                 [HRTotalCholesterolAppletTile normalLowForAge:age],
                                 [HRTotalCholesterolAppletTile normalHighForAge:age]];
    
    // calculate values based on age
    double latestValue = [[latest valueForKeyPath:@"value.scalar"] doubleValue];
    if ([HRTotalCholesterolAppletTile isValueNormal:latestValue forAge:age]) {
        self.leftValueLabel.textColor = [UIColor blackColor];
    }
    else {
        self.leftValueLabel.textColor = [UIColor hr_redColor];
    }
    self.middleValueLabel.text = [latest.date hr_shortStyleDate];
    
    // sparkline
    HRSparkLineLine *line = [[HRSparkLineLine alloc] init];
    line.outOfRangeDotColor = [UIColor hr_redColor];
    line.weight = 4.0;
    line.points = [self dataForSparkLineView];
    line.range = [HRTotalCholesterolAppletTile sparkLineRangeForAge:age];
    self.sparkLineView.lines = @[ line ];
    
}

- (NSArray *)dataForSparkLineView {
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:[_entries count]];
    [_entries enumerateObjectsUsingBlock:^(HRMEntry *entry, NSUInteger index, BOOL *stop) {
        NSTimeInterval interval = [entry.date timeIntervalSince1970];
        NSString *scalarString = [entry.value objectForKey:@"scalar"];
        CGFloat value = 0.0;
        if ([scalarString respondsToSelector:@selector(floatValue)]) {
            value = [scalarString floatValue];
        }
        HRSparkLinePoint *point = [HRSparkLinePoint pointWithX:interval y:value];
        [points addObject:point];
    }];
    return points;
}

- (NSArray *)dataForKeyValueTable {
    NSInteger age = [self ageInYears];
    NSMutableArray *entries = [NSMutableArray arrayWithCapacity:[_entries count]];
    [_entries enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(HRMEntry *entry, NSUInteger index, BOOL *stop) {
        double value = [[entry.value objectForKey:@"scalar"] doubleValue];
        BOOL normal = [HRTotalCholesterolAppletTile isValueNormal:value forAge:age];
        UIColor *color = (normal ? [UIColor blackColor] : [UIColor hr_redColor]);
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"%0.1f", value], @"detail",
                                    [entry.date hr_mediumStyleDate], @"title",
                                    color, @"detail_color",
                                    nil];
        [entries addObject:dictionary];
    }];
    return [entries copy];
}

+ (double)normalHighForAge:(NSInteger)age {
    if (age < 21) { return 169.0; }
    else { return 199.0; }
}

+ (double)normalLowForAge:(NSInteger)age {
    if (age < 21) { return 75.0; }
    else { return 100.0; }
}

+ (BOOL)isValueNormal:(double)value forAge:(NSInteger)age {
    HRSparkLineRange range = [self sparkLineRangeForAge:age];
    return HRLocationInRange(value, range);
}

+ (HRSparkLineRange)sparkLineRangeForAge:(NSInteger)age {
    double high = [self normalHighForAge:age];
    double low = [self normalLowForAge:age];
    return HRMakeRange(low, high - low);
}

- (NSInteger)ageInYears {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar
                                    components:NSMonthCalendarUnit
                                    fromDate:self.patient.dateOfBirth
                                    toDate:[NSDate date]
                                    options:0];
    return [components year];
}

@end
