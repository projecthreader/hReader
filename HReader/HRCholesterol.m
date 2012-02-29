//
//  HRCholesterol.m
//  HReader
//
//  Created by Marshall Huss on 2/6/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRCholesterol.h"

@implementation HRCholesterol

@synthesize cholesterol  = __cholesterol;

- (void)dealloc {
    [super dealloc];
}

/*
- (id)init {
    self = [super init];
    if (self) {
        self.title = @"Total Cholesterol";
    }
    
    return self;
}

- (BOOL)isNormal {
    return YES;
}

- (NSString *)resultString {
    return [NSString stringWithFormat:@"%d", self.cholesterol];
}

- (NSString *)labelString {
    return @"mg/dL";
}

- (NSString *)normalString {
    if (self.age < 12) {
        return @"120";
    } else if (self.age < 25) {
        return @"160";
    } else {
        return @"< 200";
    }
}
 */


@end
