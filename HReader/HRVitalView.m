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
@synthesize nameLabel       = __nameLabel;
@synthesize resultLabel     = __resultLabel;
@synthesize dateLabel       = __dateLabel;
@synthesize normalLabel     = __normalLabel;
@synthesize graphImageView  = __graphImageView;

- (void)dealloc {
    [__vital release];
    [__nameLabel release];
    [__resultLabel release];
    [__dateLabel release];
    [__normalLabel release];
    [__graphImageView release];
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
}

@end
