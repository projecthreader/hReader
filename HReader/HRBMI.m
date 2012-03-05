//
//  HRBMI.m
//  HReader
//
//  Created by Marshall Huss on 2/8/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRBMI.h"

@implementation HRBMI

- (BOOL)isNormal {
    double bmi = self.value;
    return !(bmi < [self normalLow] || bmi > [self normalHigh]);
}

- (NSString *)leftValue {
    return [NSString stringWithFormat:@"%0.1f", self.value];
}

- (NSString *)rightValue {
    return [NSString stringWithFormat:@"%0.1f-%0.1f", self.normalLow, self.normalHigh];
}

- (double)normalLow {
    return 18.5;
}

- (double)normalHigh {
    return 22.9;
}

@end
