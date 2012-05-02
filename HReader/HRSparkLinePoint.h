//
//  HRSparkLinePoint.h
//  CorePlotExample
//
//  Created by Marshall Huss on 4/30/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRSparkLinePoint : NSObject

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;

+ (HRSparkLinePoint *)pointWithX:(CGFloat)x y:(CGFloat)y;

@end
