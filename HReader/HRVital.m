//
//  HRVital.m
//  HReader
//
//  Created by Marshall Huss on 2/6/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRVital.h"

@implementation HRVital

@synthesize title           = __title;
@synthesize date            = __date;
@synthesize graph           = __graph;
@synthesize age             = __age;
@synthesize gender          = __gender;

- (void)dealloc {
    [__title release];
    [__date release];
    [__graph release];
    [super dealloc];
}

- (BOOL)isNormal {
    return YES;
}

- (NSString *)resultString {
    return @"-";
}

- (NSString *)normalString {
    return @"-";
}

- (NSString *)labelString {
    return @"-";
}

- (NSString *)resultLabelString {
    return @"Result:";
}

- (NSString *)normalLabelString {
    return @"Normal:";
}

@end
