//
//  HRWeight.m
//  HReader
//
//  Created by Marshall Huss on 2/6/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRWeight.h"

@interface HRWeight ()
- (NSInteger)lowForAge;
- (NSInteger)highForAge;
@end

@implementation HRWeight

@synthesize weight      = __weight;

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
    NSLog(@"%i", self.weight);
    NSLog(@"%i", [self lowForAge]);
    NSLog(@"%i", [self highForAge]);
    if (self.weight > [self lowForAge] && self.weight < [self highForAge]) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)resultString {
    return [NSString stringWithFormat:@"%d", self.weight];
}
    
- (NSString *)normalString {
    return [NSString stringWithFormat:@"%i-%i", [self lowForAge], [self highForAge]];
}

#pragma mark - private methods

- (NSInteger)lowForAge {
    if (self.age < 12) {
        return 30;
    } else if (self.age < 25) {
        return 61;
    } else {
        return 160;
    }
}

- (NSInteger)highForAge {
    if (self.age < 12) {
        return 60;
    } else if (self.age < 25) {
        return 180;
    } else {
        return 180;
    }
}

@end
