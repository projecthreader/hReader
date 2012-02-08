//
//  HRVitalView.m
//  HReader
//
//  Created by Marshall Huss on 2/8/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRVitalView.h"
#import "HRVital.h"

@implementation HRVitalView

@synthesize vital           = __vital;
@synthesize leftLabel       = __leftLabel;
@synthesize rightLabel      = __rightLabel;
@synthesize nameLabel       = __nameLabel;
@synthesize resultLabel     = __resultLabel;
@synthesize dateLabel       = __dateLabel;
@synthesize normalLabel     = __normalLabel;
@synthesize graphImageView  = __graphImageView;
@synthesize unitsLabel      = __unitsLabel;

- (void)dealloc {
    [__vital release];
    [__nameLabel release];
    [__resultLabel release];
    [__dateLabel release];
    [__normalLabel release];
    [__graphImageView release];
    [__leftLabel release];
    [__rightLabel release];
    [__unitsLabel release];
    [super dealloc];
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
    self.graphImageView.image = __vital.graph;
    
    self.leftLabel.text = [__vital.resultLabelString uppercaseString];
    self.rightLabel.text = [__vital.normalLabelString uppercaseString];
    
    self.unitsLabel.text = [__vital labelString];
}

@end
