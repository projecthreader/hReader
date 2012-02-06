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
@synthesize label           = __label;
@synthesize date            = __date;
@synthesize graph           = __graph;
@synthesize age             = __age;
@synthesize gender          = __gender;

- (void)dealloc {
    [__title release];
    [__label release];
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

- (NSString *)label {
    return @"-";
}

@end
