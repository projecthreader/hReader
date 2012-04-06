//
//  HRMEntry.m
//  HReader
//
//  Created by Caleb Davenport on 2/9/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRMEntry.h"

#import "DDXML.h"

@implementation HRMEntry

@dynamic codes;
@dynamic dose;
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
    object = [dictionary objectForKey:@"dose"];
    if (object && [object isKindOfClass:[NSDictionary class]]) {
        entry.dose = object;
    }
    
    // return
    return entry;
    
}

- (DDXMLElement *)timelineXMLElement {
    
    // get date formatter
    static NSDateFormatter *format = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MMM w yyyy '00:00:00 GMT'"];
    });
    
    // get start
    NSString *start = nil;
    if (self.date)              { start = [format stringFromDate:self.date];        }
    else if (self.startDate)    { start = [format stringFromDate:self.startDate];   }
    else if (self.endDate)      { start = [format stringFromDate:self.endDate];     }
    
    // get type
    short type = [self.type shortValue];
    NSString *category = nil;
    if (type == HRMEntryTypeAllergy)            { category = @"allergies";      }
    else if (type == HRMEntryTypeCondition)     { category = @"conditions";     }
    else if (type == HRMEntryTypeResult)        { category = @"results";        }
    else if (type == HRMEntryTypeEncounter)     { category = @"encounters";     }
    else if (type == HRMEntryTypeVitalSign)     { category = @"vitals";         }
    else if (type == HRMEntryTypeImmunization)  { category = @"immunizations";  }
    else if (type == HRMEntryTypeMedication)    { category = @"medications";    }
    else if (type == HRMEntryTypeProcedure)     { category = @"procedures";     }
    
    NSMutableString *eventDesc = [NSMutableString string];
    [eventDesc appendFormat:@"%@", self.desc];
    if (type == HRMEntryTypeVitalSign) {
        [eventDesc appendFormat:@" - %.2f", [[self.value objectForKey:@"scalar"] doubleValue]];
    }
    
    // create element
    DDXMLElement *element = [DDXMLElement elementWithName:@"event" stringValue:eventDesc];
    [element addAttribute:[DDXMLElement attributeWithName:@"title" stringValue:@""]];
    [element addAttribute:[DDXMLElement attributeWithName:@"category" stringValue:category]];
    [element addAttribute:[DDXMLElement attributeWithName:@"start" stringValue:start]];
    
    // return
    return element;
    
}

@end
