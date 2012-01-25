//
//  HRCondition.m
//  HReader
//
//  Created by Marshall Huss on 1/25/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRCondition.h"

@implementation HRCondition

@synthesize name        = __name;
@synthesize description = __desription;
@synthesize date        = __date;
@synthesize chronic     = __chronic;

- (id)initWithName:(NSString *)name description:(NSString  *)description date:(NSDate *)date chronic:(BOOL)chronic {
    self = [super init];
    if (self) {
        self.name = name;
        self.description = description;
        self.date = date;
        self.chronic = chronic;
    }
    
    return self;
}


@end
