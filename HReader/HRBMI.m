//
//  HRBMI.m
//  HReader
//
//  Created by Marshall Huss on 2/8/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRBMI.h"

@implementation HRBMI

- (id)init {
    self = [super init];
    if (self) {
        self.title = @"BMI";
    }
    
    return self;
}

- (BOOL)isNormal {
    return YES;
}

- (NSString *)resultString {
    return @"200";
}

- (NSString *)labelString {
    return @"mg/dL";
}

- (NSString *)normalString {
    return @"180-200";
}


@end
