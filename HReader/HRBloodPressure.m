//
//  HRCholesterol.m
//  HReader
//
//  Created by Marshall Huss on 2/6/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRBloodPressure.h"

@implementation HRBloodPressure

@synthesize systolic        = __systolic;
@synthesize diastolic       = __diastolic;

- (id)init {
    self = [super init];
    if (self) {
        self.title = @"Blood Pressure";
        self.label = @"";
    }
    
    return self;
}

- (BOOL)isNormal {
    return YES;
}

- (NSString *)resultString {
    return [NSString stringWithFormat:@"%i/%i", self.systolic, self.diastolic];
}

- (NSString *)normalString {
    if (self.age < 12) {
        return @"X/X";
    } else if (self.age < 25) {
        return @"X/X";
    } else {
        return @"X/X";
    }
}


@end
