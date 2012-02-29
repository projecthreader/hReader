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
    
    self.resultLabel.text = __vital.resultString;
    if (self.vital.isNormal) {
        self.resultLabel.textColor = [UIColor blackColor];
    } else {
        self.resultLabel.textColor = [UIColor redColor];
    }
    
    self.normalLabel.text = __vital.normalString;
//    self.graphImageView.image = __vital.graph;
    self.sparkLineView.dataValues = [self randomData];
    self.sparkLineView.labelText = @"";
    self.sparkLineView.showCurrentValue = NO;
    self.sparkLineView.penWidth = 6.0;
    self.sparkLineView.showRangeOverlay = YES;
    self.sparkLineView.rangeOverlayLowerLimit = [NSNumber numberWithFloat:20.0];
    self.sparkLineView.rangeOverlayUpperLimit = [NSNumber numberWithFloat:80.0];
    self.sparkLineView.rangeOverlayColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    self.leftLabel.text = [__vital.resultLabelString uppercaseString];
    self.rightLabel.text = [__vital.normalLabelString uppercaseString];
    
    self.unitsLabel.text = [__vital labelString];
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
