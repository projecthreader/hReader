//
//  UITBITaskSlider.m
//  HReader
//
//  Created by Saltzman, Shep on 10/11/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "UITBITaskSlider.h"

@implementation UITBITaskSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setMinimumValueImage:[UIImage imageNamed:@"slider"]];
        [self setMinimumTrackImage:[UIImage imageNamed:@"slider"] forState:0];
        [self setThumbImage:[UIImage imageNamed:@"slider"] forState:0];
        [self setMaximumTrackImage:[UIImage imageNamed:@"slider"] forState:0];
        [self setMaximumValueImage:[UIImage imageNamed:@"slider"]];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
