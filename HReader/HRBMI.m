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
    float bmi = self.value;
    return !(bmi < [self normalLow] || bmi > [self normalHigh]);

}
- (NSString *)leftValue {
    
    return [NSString stringWithFormat:@"%0.1f", self.value];
}
- (NSString *)rightValue {
    return [NSString stringWithFormat:@"%0.1f-%0.1f", self.normalLow, self.normalHigh];
}
- (float)normalLow {
    return 18.5;
}
- (float)normalHigh {
    return 22.9;
}

@end
