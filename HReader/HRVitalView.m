//
//  HRVitalView.m
//  HReader
//
//  Created by Marshall Huss on 2/8/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRVitalView.h"
#import "HRVital.h"

#import "ASBSparkLineView.h"

#import "NSArray+Collect.h"

#import "NSDate+FormattedDate.h"

@implementation HRVitalView

@synthesize vital           = __vital;
@synthesize leftLabel       = __leftLabel;
@synthesize rightLabel      = __rightLabel;
@synthesize nameLabel       = __nameLabel;
@synthesize resultLabel     = __resultLabel;
@synthesize dateLabel       = __dateLabel;
@synthesize normalLabel     = __normalLabel;
@synthesize unitsLabel      = __unitsLabel;
@synthesize sparkLineView   = __sparkLineView;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.sparkLineView.backgroundColor = [UIColor whiteColor];
    self.resultLabel.adjustsFontSizeToFitWidth = YES;
    self.normalLabel.adjustsFontSizeToFitWidth = YES;
    self.dateLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)setVital:(HRVital *)vital {
    
    // save
    __vital = vital;
    
    // set labels
    self.nameLabel.text = [vital.title uppercaseString];
    self.leftLabel.text = [vital.leftTitle uppercaseString];
    self.rightLabel.text = [vital.rightTitle uppercaseString];
    self.resultLabel.text = vital.leftValue;
    self.dateLabel.text = [vital.date shortStyleDate];
    self.unitsLabel.text = vital.leftUnit;
    self.normalLabel.text = vital.rightValue;
    
    // sparklines
    self.sparkLineView.labelText = @"";
    self.sparkLineView.showCurrentValue = NO;
    self.sparkLineView.penWidth = 6.0;
    self.sparkLineView.showRangeOverlay = YES;
    self.sparkLineView.rangeOverlayLowerLimit = [NSNumber numberWithDouble:vital.normalLow];
    self.sparkLineView.rangeOverlayUpperLimit = [NSNumber numberWithDouble:vital.normalHigh];
    self.sparkLineView.rangeOverlayColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    NSArray *scalarStrings = [vital.entries valueForKeyPath:@"value.scalar"];
    NSArray *scalars = [scalarStrings collect:^(id object, NSUInteger idx) {
        if ([object isKindOfClass:[NSString class]]) {
            float value = [object floatValue];
            return [NSNumber numberWithDouble:value];
        }
        else {
            return [NSNumber numberWithDouble:0.0];
        }
    }];
    self.sparkLineView.dataValues = scalars;
    
    // display normal value
    if (vital.isNormal) {
        self.resultLabel.textColor = [UIColor blackColor];
    } else {
        self.resultLabel.textColor = [HRConfig redColor];
    }
    
}

@end
