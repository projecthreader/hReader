//
//  HREncounter.m
//  HReader
//
//  Created by Marshall Huss on 1/9/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HREncounter.h"

@implementation HREncounter

@synthesize title   = __title;
@synthesize code    = __code;
@synthesize date    = __date;

- (id)initWithTitle:(NSString *)title code:(NSString *)code date:(NSDate *)date {
    self = [super init];
    if (self) {
        self.title = title;
        self.code = code;
        self.date = date;
    }
    
    return self;
}

@end
