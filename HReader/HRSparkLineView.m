//
//  HRSparkLineView.m
//  HReader
//
//  Created by Marshall Huss on 4/16/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRSparkLineView.h"

@implementation HRSparkLineView

- (void)awakeFromNib {
    self.backgroundColor = [UIColor whiteColor];
    self.labelText = @"";
    self.showCurrentValue = NO;
    self.penWidth = 6.0;
    self.showRangeOverlay = YES;
    self.rangeOverlayColor = [UIColor colorWithWhite:0.9 alpha:1.0];
}

@end
