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
#import "HRMPatient.h"

#import "NSDate+FormattedDate.h"
#import "NSArray+Collect.h"

@implementation HRBMIVitalAppletTile {
    NSArray *_entries;
}

- (void)tileDidLoad {
    [super tileDidLoad];
    
    // save points
    _entries = [self.patient vitalSignsWithType:@"BMI"];
    HRMEntry *latest = [_entries lastObject];
    
    // set labels
    float latestValue = [[latest valueForKeyPath:@"value.scalar"] floatValue];
    self.leftValueLabel.textColor = ([self isValueNormal:latestValue]) ? [UIColor blackColor] : [UIColor hr_redColor];
    self.middleValueLabel.text = [latest.date shortStyleDate];
    
    HRSparkLineRange range;
    HRSparkLineLine *line = [[HRSparkLineLine alloc] init];
    line.outOfRangeDotColor = [UIColor hr_redColor];
    line.weight = 4.0;
    line.points = [self dataForSparkLineView];
    
    float val = [[latest valueForKeyPath:@"value.scalar"] floatValue];
    
    if ([self isChild]) {
        self.leftTitleLabel.text = [@"percentile:" uppercaseString];
        self.leftValueLabel.text = [NSString stringWithFormat:@"%ld", (long)[self percentileForBMIEntry:latest]];
        self.rightValueLabel.text = @"25th-75th";
        
        // display normal value
        NSInteger percentile = [self percentileForBMIEntry:latest];
        if ((percentile >= 25) || (percentile <= 75)) {
            self.rightValueLabel.textColor = [UIColor blackColor];
        }
        else {
            self.rightValueLabel.textColor = [UIColor hr_redColor];
        }
        
        range = HRMakeRange(25.0, 75.0 - 25.0);
    }
    else {
        self.leftTitleLabel.text = [@"recent result:" uppercaseString];
        self.leftValueLabel.text = [NSString stringWithFormat:@"%0.1f", latestValue];  
        self.rightValueLabel.text = [NSString stringWithFormat:@"%0.0f-%0.0f", [self normalLow], [self normalHigh]];
        
        // display normal value
        self.rightValueLabel.textColor = ([self isValueNormal:val]) ? [UIColor blackColor] : [UIColor hr_redColor];
        
        range = HRMakeRange([self normalLow], [self normalHigh] - [self normalLow]);
    }
    
    // sparkline
    line.range = range;
    self.sparkLineView.lines = [NSArray arrayWithObject:line];
    
}

- (NSArray *)dataForKeyValueTable {
    NSMutableArray *entries = [NSMutableArray arrayWithCapacity:[_entries count]];
    [_entries enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(HRMEntry *entry, NSUInteger index, BOOL *stop) {
        double value = [[entry.value objectForKey:@"scalar"] doubleValue];
        BOOL isNormal = [self isValueNormal:value];
        UIColor *color = isNormal ? [UIColor blackColor] : [UIColor hr_redColor];
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
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:[_entries count]];
    [_entries enumerateObjectsUsingBlock:^(HRMEntry *entry, NSUInteger index, BOOL *stop) {
        NSTimeInterval timeInterval = [entry.date timeIntervalSince1970];
        CGFloat value = 0.0;
        if ([self isChild]) {
            value = [self percentileForBMIEntry:entry];
        }
        else {        
            NSString *scalarString = [entry.value objectForKey:@"scalar"];
            if ([scalarString isKindOfClass:[NSString class]]) {
                value = [scalarString floatValue];    
            }
        }
        HRSparkLinePoint *point = [HRSparkLinePoint pointWithX:timeInterval y:value];
        [points addObject:point];
    }];
    return points;
}

#pragma mark - private

- (NSDictionary *)BMIChartForGender:(HRMPatientGender)gender {
    
    // load charts
    static NSDictionary *femaleBMIChart = nil;
    static NSDictionary *maleBMIChart = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSError *error = nil;
        NSURL *URL = nil;
        NSData *data = nil;
        
        // male
        URL = [[NSBundle mainBundle] URLForResource:@"male-bmi-chart" withExtension:@"json"];
        data = [NSData dataWithContentsOfURL:URL];
        maleBMIChart = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSAssert(maleBMIChart, @"Error reading male BMI chart\n%@", error);
        
        // female
        URL = [[NSBundle mainBundle] URLForResource:@"female-bmi-chart" withExtension:@"json"];
        data = [NSData dataWithContentsOfURL:URL];
        femaleBMIChart = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSAssert(femaleBMIChart, @"Error reading female BMI chart\n%@", error);
        
    });
    
    // return
    if (gender == HRMPatientGenderMale) { return maleBMIChart; }
    else { return femaleBMIChart; }
    
}

- (NSInteger)percentileForBMIEntry:(HRMEntry *)entry {
    
    // get recorded bmi
    id scalar = [entry.value objectForKey:@"scalar"];
    CGFloat BMI = 0.0;
    if ([scalar isKindOfClass:[NSString class]]) {
        BMI = [scalar floatValue];
    }
    
    // get chart
    NSDictionary *chart = [self BMIChartForGender:[self.patient.gender integerValue]];
    
    // chart uses half months as the keys, so 30 months will be looked up as 30.5
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSMonthCalendarUnit
                                               fromDate:self.patient.dateOfBirth
                                                 toDate:entry.date
                                                options:0];
    NSInteger months = [components month];
    NSArray *row = [chart objectForKey:[NSString stringWithFormat:@"%ld.5", (long)months]];
    
    __block NSInteger percentile = 0;
    [row enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (BMI > [obj floatValue]) {
            if (idx == 0) { percentile = 3; }
            else if (idx == [row count] - 1) { percentile = 97; }
            else { percentile = idx * 5; }
            *stop = YES;
        }
    }];
    
    if (percentile == 0) { percentile = 3; }
    return percentile;
    
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

- (BOOL)isChild {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSMonthCalendarUnit
                                               fromDate:self.patient.dateOfBirth
                                                 toDate:[NSDate date]
                                                options:0];
    return ([components month] <= 240);
}

@end
