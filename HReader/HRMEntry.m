//
//  HRMEntry.m
//  HReader
//
//  Created by Caleb Davenport on 2/9/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRMEntry.h"

@implementation HRMEntry

@dynamic codes;
@dynamic date;
@dynamic desc;
@dynamic endDate;
@dynamic startDate;
@dynamic status;
@dynamic value;
@dynamic type;
@dynamic patient;

+ (HRMEntry *)instanceWithDictionary:(NSDictionary *)dictionary
                                type:(HRMEntryType)type
                           inContext:(NSManagedObjectContext *)context {
    
    // create entry
    HRMEntry *entry = [self instanceInContext:context];
    entry.type = [NSNumber numberWithShort:type];
    id object = nil;
    
    // set properties
    object = [dictionary objectForKey:@"description"];
    if (object && [object isKindOfClass:[NSString class]]) {
        entry.desc = object;
    }
    object = [dictionary objectForKey:@"status"];
    if (object && [object isKindOfClass:[NSString class]]) {
        entry.status = object;
    }
    object = [dictionary objectForKey:@"time"];
    if (object && [object isKindOfClass:[NSNumber class]]) {
        NSTimeInterval stamp = [object doubleValue];
        entry.date = [NSDate dateWithTimeIntervalSince1970:stamp];
    }
    object = [dictionary objectForKey:@"start_time"];
    if (object && [object isKindOfClass:[NSNumber class]]) {
        NSTimeInterval stamp = [object doubleValue];
        entry.startDate = [NSDate dateWithTimeIntervalSince1970:stamp];
    }
    object = [dictionary objectForKey:@"end_time"];
    if (object && [object isKindOfClass:[NSNumber class]]) {
        NSTimeInterval stamp = [object doubleValue];
        entry.endDate = [NSDate dateWithTimeIntervalSince1970:stamp];
    }
    object = [dictionary objectForKey:@"codes"];
    if (object && [object isKindOfClass:[NSDictionary class]]) {
        entry.codes = object;
    }
    object = [dictionary objectForKey:@"value"];
    if (object && [object isKindOfClass:[NSDictionary class]]) {
        entry.value = object;
    }
    
    // return
    return entry;
    
}

- (NSString *)timelineCategory {
    short type = [self.type shortValue];
    if (type == HRMEntryTypeAllergy) {
        return @"allergies";
    }
    else if (type == HRMEntryTypeCondition) {
        return @"conditions";
    }
    else if (type == HRMEntryTypeResult) {
        return @"results";
    }
    else if (type == HRMEntryTypeEncounter) {
        return @"encounters";
    }
    else if (type == HRMEntryTypeVitalSign) {
        return @"vitals";
    }
    else if (type == HRMEntryTypeImmunization) {
        return @"immunizations";
    }
    else if (type == HRMEntryTypeMedication) {
        return @"medications";
    }
    else if (type == HRMEntryTypeProcedure) {
        return @"procedures";
    }
    else {
        return nil;
    }
}
- (NSString *)timelineDateAsString {
    static NSDateFormatter *format = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MMM w yyyy '00:00:00 GMT'"];
    });
    if (self.date) {
        return [format stringFromDate:self.date];
    }
    else if (self.startDate) {
        return [format stringFromDate:self.startDate];
    }
    else if (self.endDate) {
        return [format stringFromDate:self.endDate];
    }
    else {
        return nil;
    }
}

@end
