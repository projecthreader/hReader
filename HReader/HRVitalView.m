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

@synthesize vital           = __vital;
@synthesize leftLabel       = __leftLabel;
@synthesize rightLabel      = __rightLabel;
@synthesize nameLabel       = __nameLabel;
@synthesize resultLabel     = __resultLabel;
@synthesize dateLabel       = __dateLabel;
@synthesize normalLabel     = __normalLabel;
@synthesize unitsLabel      = __unitsLabel;
@synthesize sparkLineView   = __sparkLineView;

- (void)dealloc {
    [__vital release];
    [__nameLabel release];
    [__resultLabel release];
    [__dateLabel release];
    [__normalLabel release];
    [__leftLabel release];
    [__rightLabel release];
    [__unitsLabel release];
    [__sparkLineView release];
    [super dealloc];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.sparkLineView.backgroundColor = [UIColor whiteColor];    
}


- (void)setVital:(HRVital *)vital {
    [__vital release];
    __vital = [vital retain];
    self.nameLabel.text = [__vital.title uppercaseString];
    
    self.resultLabel.text = __vital.leftValue;
    if (self.vital.isNormal) {
        self.resultLabel.textColor = [UIColor blackColor];
    } else {
        self.resultLabel.textColor = [UIColor redColor];
    }
    
    self.dateLabel.text = [vital.date shortDate];
    
    // sparklines
    NSArray *scalarStrings = [vital.entries valueForKeyPath:@"value.scalar"];
//    NSLog(@"%@", scalarStrings);
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
    
    self.normalLabel.adjustsFontSizeToFitWidth = YES;
    self.normalLabel.text = __vital.rightValue;
//    self.graphImageView.image = __vital.graph;
    
//    self.sparkLineView.dataValues = [self randomData];
    self.sparkLineView.labelText = @"";
    self.sparkLineView.showCurrentValue = NO;
    self.sparkLineView.penWidth = 6.0;
    self.sparkLineView.showRangeOverlay = YES;
    self.sparkLineView.rangeOverlayLowerLimit = [NSNumber numberWithFloat:vital.normalLow];
    self.sparkLineView.rangeOverlayUpperLimit = [NSNumber numberWithFloat:vital.normalHigh];
    self.sparkLineView.rangeOverlayColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    self.leftLabel.text = [__vital.leftTitle uppercaseString];
    self.rightLabel.text = [__vital.rightTitle uppercaseString];
    
    self.unitsLabel.text = __vital.leftUnit;
}

- (NSArray *)randomData {
    NSMutableArray *data = [[NSMutableArray alloc] init];
    for (int i = 0; i < 20; i++) {
        u_int32_t random = arc4random() % 100;
        [data addObject:[NSNumber numberWithInt:random]];
    }

    return (NSArray *)data;
}

@end
