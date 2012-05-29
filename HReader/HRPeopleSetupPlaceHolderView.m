//
//  HRPeopleSetupPlaceHolderView.m
//  HReader
//
//  Created by Caleb Davenport on 5/29/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRPeopleSetupPlaceHolderView.h"

@implementation HRPeopleSetupPlaceHolderView

- (void)drawRect:(CGRect)rect {
    
    // constants
    static CGFloat const dash[] = {5.0, 5.0};
    static CGFloat const radius = 20.0;
    static CGFloat const width = 4.0;
    CGSize size = self.bounds.size;
    
    // configure context
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:0.0 alpha:0.35] CGColor]);
    CGContextSetLineWidth(context, width);
    CGContextSetLineDash(context, 0.0, dash, 2);
    
    // draw lines
    CGContextMoveToPoint(context,
                         floor(radius + width / 2.0),
                         floor(width / 2.0));
    CGContextAddArcToPoint(context,
                           floor(size.width - width / 2.0),
                           floor(width / 2.0),
                           floor(size.width - width / 2.0),
                           floor(radius / 2.0 + width / 2.0),
                           radius);
    CGContextAddArcToPoint(context,
                           floor(size.width - width / 2.0),
                           floor(size.height - width / 2.0),
                           floor(size.width - width / 2.0 - radius),
                           floor(size.height - width / 2.0),
                           radius);
    CGContextAddArcToPoint(context,
                           floor(width / 2.0),
                           floor(size.height - width / 2.0),
                           floor(width / 2.0),
                           floor(size.height - width / 2.0 - radius),
                           radius);
    CGContextAddArcToPoint(context,
                           floor(width / 2.0),
                           floor(width / 2.0),
                           floor(width / 2.0 + radius),
                           floor(width / 2.0),
                           radius);

    // stroke
    CGContextStrokePath(context);
    
}


@end
