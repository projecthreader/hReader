//
//  HRSparklineRange.h
//  CorePlotExample
//
//  Created by Marshall Huss on 4/30/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#ifndef HRSparklineRange_h
#define HRSparklineRange_h

typedef struct {
    CGFloat location;
    CGFloat length;
} HRSparkLineRange;

#define HRIsZeroRange(a) (a.location == 0 && a.length == 0)
#define HRZeroRange (HRSparkLineRange){ 0, 0 }
#define HRMakeRange(a, b) (HRSparkLineRange){ a, b }
#define HRMaxRange(a) (a.location + a.length)
#define HRLocationInRange(a, b) (a >= b.location && a < HRMaxRange(b))

#endif
