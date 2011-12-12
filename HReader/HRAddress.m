//
//  HRAddress.m
//  HReader
//
//  Created by Marshall Huss on 12/12/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "HRAddress.h"

@implementation HRAddress

@synthesize street1 = __street1;
@synthesize street2 = __street2;
@synthesize city    = __city;
@synthesize state   = __state;
@synthesize zip     = __zip;

- (void)dealloc {
    [__street1 release];
    [__street2 release];
    [__city release];
    [__state release];
    [__zip release];
    
    [super dealloc];
}

- (id)initWithSteet1:(NSString *)street1 street2:(NSString *)street2 city:(NSString *)city state:(NSString *)state zip:(NSString *)zip {
    self = [super init];
    if (self) {
        self.street1 = street1;
        self.street2 = street2;
        self.city = city;
        self.state = state;
        self.zip = zip;
    }
    
    return self;
}



@end
