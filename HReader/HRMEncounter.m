//
//  HRMEncounter.m
//  HReader
//
//  Created by Caleb Davenport on 2/7/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRMEncounter.h"
#import "HRMPatient.h"


@implementation HRMEncounter

@dynamic date;
@dynamic name;
@dynamic patient;
@dynamic codes;

+ (id)instanceWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
    
    // vars
    id object = nil;
    Class class = [NSNull class];
    
    // create patient
    HRMEncounter *encounter = [HRMEncounter instanceInContext:context];
    
    // load basic data
    object = [dictionary objectForKey:@"time"];
    if (object && ![object isKindOfClass:class]) {
        NSTimeInterval stamp = [object doubleValue];
        encounter.date = [NSDate dateWithTimeIntervalSince1970:stamp];
    }
    object = [dictionary objectForKey:@"description"];
    if (object && ![object isKindOfClass:class]) {
        encounter.name = object;
    }
    object = [dictionary objectForKey:@"codes"];
    if (object && ![object isKindOfClass:class]) {
        encounter.codes = object;
    }

    // return
    return encounter;
    
}

@end
