//
//  HRWeight.m
//  HReader
//
//  Created by Marshall Huss on 2/6/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRWeight.h"

@implementation HRWeight

@synthesize weight  = __weight;

- (void)dealloc {
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        self.title = @"Weight";
        self.label = @"lbs";
    }
    
    return self;
}

- (BOOL)isNormal {
    return YES;
}

- (NSString *)resultString {
    return [NSString stringWithFormat:@"%d", self.weight];
}
    
- (NSString *)normalString {
    if (self.age < 12) {
        return @"30-60";
    } else if (self.age < 25) {
        return @"61-180";
    } else {
        return @"160-200";
    }
}

@end
