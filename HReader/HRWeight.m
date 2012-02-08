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
    }
    
    return self;
}

// Is the patient in the normal range?
- (BOOL)isNormal {
    if (self.age < 13) {
        return YES;
    } else {
        if (self.weight > [self lowForAge] && self.weight < [self highForAge]) {
            return YES;
        } else {
            return NO;
        }   
    }
}

// Result
- (NSString *)resultString {
    if (self.age < 13) {
        return @"25";
    } else {
        return [NSString stringWithFormat:@"%d", self.weight];           
    }
    
}
  
// Normal range for the user
- (NSString *)normalString {
    if (self.age < 13) {
        return [NSString stringWithFormat:@"%i", self.weight];
    } else {
        return [NSString stringWithFormat:@"%i-%i", [self lowForAge], [self highForAge]];
    }
}

// Units label
- (NSString *)labelString {
    if (self.age < 13) {
        return @"TH";
    } else {
        return @"lbs";
    }
}

// Label for result
- (NSString *)resultLabelString {
    if (self.age < 13) {
        return @"Percentile:";
    } else {
        return @"Result:";
    }    
}


// Label for normal level
- (NSString *)normalLabelString {
    if (self.age < 13) {
        return @"Recent:";
    } else {
        return @"Normal:";
    }
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
