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
#import "NSDate+HReaderAdditions.h"

@implementation HRVitalView

@synthesize leftLabel       = __leftLabel;
@synthesize rightLabel      = __rightLabel;
@synthesize nameLabel       = __nameLabel;
@synthesize resultLabel     = __resultLabel;
@synthesize dateLabel       = __dateLabel;
@synthesize normalLabel     = __normalLabel;
@synthesize unitsLabel      = __unitsLabel;
@synthesize sparkLineView   = __sparkLineView;

- (void)dealloc {
    self.nameLabel = nil;
    self.rightLabel = nil;
    self.leftLabel = nil;
    self.resultLabel = nil;
    self.dateLabel = nil;
    self.normalLabel = nil;
    self.unitsLabel = nil;
    self.sparkLineView = nil;
    [super dealloc];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.sparkLineView.backgroundColor = [UIColor whiteColor];
    self.resultLabel.adjustsFontSizeToFitWidth = YES;
    self.normalLabel.adjustsFontSizeToFitWidth = YES;
    self.dateLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)showVital:(HRVital *)vital {
    
    // set labels
    self.nameLabel.text = [vital.title uppercaseString];
    self.leftLabel.text = [vital.leftTitle uppercaseString];
    self.rightLabel.text = [vital.rightTitle uppercaseString];
    self.resultLabel.text = vital.leftValue;
    self.dateLabel.text = [vital.date shortDate];
    self.unitsLabel.text = vital.leftUnit;
    self.normalLabel.text = vital.rightValue;
    
    // sparklines
    self.sparkLineView.labelText = @"";
    self.sparkLineView.showCurrentValue = NO;
    self.sparkLineView.penWidth = 6.0;
    self.sparkLineView.showRangeOverlay = YES;
    self.sparkLineView.rangeOverlayLowerLimit = [NSNumber numberWithFloat:vital.normalLow];
    self.sparkLineView.rangeOverlayUpperLimit = [NSNumber numberWithFloat:vital.normalHigh];
    self.sparkLineView.rangeOverlayColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    NSArray *scalarStrings = [vital.entries valueForKeyPath:@"value.scalar"];
    NSArray *scalars = [scalarStrings collect:^(id object, NSUInteger idx) {
        if ([object isKindOfClass:[NSString class]]) {
            float value = [object floatValue];
            return [NSNumber numberWithFloat:value];
        }
        else {
            return [NSNumber numberWithFloat:0.0];
        }
    }];
    self.sparkLineView.dataValues = scalars;
    
    // display normal value
    if (vital.isNormal) {
        self.resultLabel.textColor = [UIColor blackColor];
    } else {
        self.resultLabel.textColor = [UIColor redColor];
    }
    
}

@end
