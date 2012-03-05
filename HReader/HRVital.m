//
//  HRVital.m
//  HReader
//
//  Created by Marshall Huss on 2/6/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRVital.h"

@interface HRVital ()
@property (nonatomic, copy, readwrite) NSArray *entries;
@end

@implementation HRVital

@synthesize entries = __entries;

- (void)dealloc {
    self.entries = nil;
    [super dealloc];
}

- (id)initWithEntries:(NSArray *)entries {
    self = [super init];
    if (self) {
        self.entries = entries;
    }
    return self;
}

- (BOOL)isNormal {
    return YES;
}

- (NSString *)title {
    return [[self.entries lastObject] desc];
}

- (NSDate *)date {
    return [[self.entries lastObject] date];
}
- (NSString *)leftTitle {
    return @"RESULT:";
}
- (NSString *)leftValue {
    return [NSString stringWithFormat:@"%0.1f", self.value];
}
- (NSString *)leftUnit {
    return nil;
}
- (NSString *)rightTitle {
    return @"NORMAL:";
}
- (NSString *)rightValue {
    return nil;
}
- (double)normalLow {
    return 0.0;
}

- (double)normalHigh {
    return 0.0;
}

- (double)value {
    HRMEntry *entry = [self.entries lastObject];
    return [[entry.value objectForKey:@"scalar"] floatValue];
}

@end
