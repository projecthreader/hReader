//
//  HRMPatient.m
//  HReader
//
//  Created by Caleb Davenport on 2/7/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRMPatient.h"
#import "HRMEntry.h"

#import "DDXML.h"

#if !__has_feature(objc_arc)
#error This class requires ARC
#endif

@interface HRMPatient ()

/*
 
 Fetch an array of entries belonging to the receiver sorted and filtered with
 the provided parameters.
 
 */
- (NSArray *)entriesWithType:(HRMEntryType)type;
- (NSArray *)entriesWithType:(HRMEntryType)type sortDescriptors:(NSArray *)sortDescriptors;
- (NSArray *)entriesWithType:(HRMEntryType)type sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate;

@end

@implementation HRMPatient

@dynamic dateOfBirth;
@dynamic firstName;
@dynamic lastName;
@dynamic race;
@dynamic ethnicity;
@dynamic gender;
@dynamic compositeName;
@dynamic genderString;
@dynamic entries;
@dynamic syntheticInfo;

@dynamic immunizations;
@dynamic results;
@dynamic allergies;
@dynamic procedures;

@synthesize applets = __applets;

#pragma mark - class methods

+ (HRMPatient *)instanceWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
    
    // create patient
    HRMPatient *patient = [HRMPatient instanceInContext:context];
    __block id object = nil;
    
    // load basic data
    object = [dictionary objectForKey:@"first"];
    if (object && [object isKindOfClass:[NSString class]]) {
        patient.firstName = object;
    }
    object = [dictionary objectForKey:@"last"];
    if (object && [object isKindOfClass:[NSString class]]) {
        patient.lastName = object;
    }
    object = [dictionary objectForKey:@"race"];
    if (object && [object isKindOfClass:[NSString class]]) {
        patient.race = object;
    }
    object = [dictionary objectForKey:@"ethnicity"];
    if (object && [object isKindOfClass:[NSString class]]) {
        patient.ethnicity = object;
    }
    object = [dictionary objectForKey:@"birthdate"];
    if (object && [object isKindOfClass:[NSNumber class]]) {
        NSTimeInterval stamp = [object doubleValue];
        patient.dateOfBirth = [NSDate dateWithTimeIntervalSince1970:stamp];
    }
    object = [dictionary objectForKey:@"gender"];
    if (object && [object isKindOfClass:[NSString class]]) {
        if ([object isEqualToString:@"M"]) {
            patient.gender = [NSNumber numberWithUnsignedInteger:HRMPatientGenderMale];
        }
        else if ([object isEqualToString:@"F"]) {
            patient.gender = [NSNumber numberWithUnsignedInteger:HRMPatientGenderFemale];
        }
    }
    
    // define block for iterating over collections
    void (^collectionBlock) (HRMEntryType, NSString *) = ^(HRMEntryType type, NSString *key) {
        object = [dictionary objectForKey:key];
        if (object && [object isKindOfClass:[NSArray class]]) {
            [object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                    HRMEntry *entry = [HRMEntry
                                       instanceWithDictionary:obj
                                       type:type
                                       inContext:context];
                    [patient addEntriesObject:entry];
                }
            }];
        }
    };
    
    // encounters
    collectionBlock(HRMEntryTypeEncounter, @"encounters");
    collectionBlock(HRMEntryTypeCondition, @"conditions");
    collectionBlock(HRMEntryTypeAllergy, @"allergies");
    collectionBlock(HRMEntryTypeMedication, @"medications");
    collectionBlock(HRMEntryTypeProcedure, @"procedures");
    collectionBlock(HRMEntryTypeResult, @"results");
    collectionBlock(HRMEntryTypeVitalSign, @"vital_signs");
    collectionBlock(HRMEntryTypeImmunization, @"immunizations");
    
    // return
    return patient;
    
}

#pragma mark - attribute overrides

- (NSString *)compositeName {
    [self willAccessValueForKey:@"compositeName"];
    NSString *name = [NSString
                      stringWithFormat:@"%@ %@*",
                      self.firstName,
                      self.lastName];
    [self didAccessValueForKey:@"compositeName"];
    return name;
}

- (NSString *)genderString {
    [self willAccessValueForKey:@"genderString"];
    NSString *gender = @"Unknown";
    if ([self.gender unsignedIntegerValue] == HRMPatientGenderMale) {
        gender = @"Male";
    }
    else if ([self.gender unsignedIntegerValue] == HRMPatientGenderFemale) {
        gender = @"Female";
    }
    [self didAccessValueForKey:@"genderString"];
    return gender;
}

#pragma mark - fetch entries

- (NSArray *)entriesWithType:(HRMEntryType)type {
    return [self entriesWithType:type sortDescriptors:nil predicate:nil];
}

- (NSArray *)entriesWithType:(HRMEntryType)type sortDescriptors:(NSArray *)sortDescriptors {
    return [self entriesWithType:type sortDescriptors:sortDescriptors predicate:nil];
}

- (NSArray *)entriesWithType:(HRMEntryType)type sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate {
    NSPredicate *typePredicate = [NSPredicate predicateWithFormat:@"type == %@", [NSNumber numberWithShort:type]];
    NSPredicate *patientPredicate = [NSPredicate predicateWithFormat:@"patient == %@", self];
    NSPredicate *basePredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:typePredicate, patientPredicate, nil]];
    if (predicate) {
        NSArray *subPredicates = [NSArray arrayWithObjects:basePredicate, predicate, nil];
        return [HRMEntry allInContext:[self managedObjectContext] 
                        withPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:subPredicates]
                      sortDescriptors:sortDescriptors];
    }
    else {
        return [HRMEntry allInContext:[self managedObjectContext] 
                        withPredicate:basePredicate
                      sortDescriptors:sortDescriptors];
    }
}

#pragma mark - object methods

- (void)awakeFromFetch {
    NSArray *applets = [self.syntheticInfo objectForKey:@"applets"];
    if (applets) {
        self.applets = [applets mutableCopy];
    }
    else {
        self.applets = [NSMutableArray array];
    }
}

- (UIImage *)patientImage {
    return [UIImage imageNamed:[NSString stringWithFormat:@"UserImage-%@-%@", self.lastName, self.firstName]];
}

- (DDXMLElement *)timelineXMLDocument {
    
    // create root
    DDXMLElement *data = [DDXMLElement elementWithName:@"data"];
    [data addAttribute:[DDXMLElement attributeWithName:@"wiki-url" stringValue:@"http://simile.mit.edu/shelf/"]];
    [data addAttribute:[DDXMLElement attributeWithName:@"wiki-section" stringValue:@"Simile Monet Timeline"]];
    
    // create events
    [self.entries enumerateObjectsUsingBlock:^(HRMEntry *entry, BOOL *stop) {
        DDXMLElement *event = [entry timelineXMLElement];
        [data addChild:event];
    }];
    
    // return
    return data;
    
}

- (NSURL *)C32HTMLURL {
    NSString *string = [NSString stringWithFormat:@"C32-%@-%@", self.lastName, self.firstName];
    return [[NSBundle mainBundle] URLForResource:string withExtension:@"html"];
}

- (NSArray *)vitalSignsWithType:(NSString *)type {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"desc LIKE[cd] %@", type];
    return [self entriesWithType:HRMEntryTypeVitalSign 
                 sortDescriptors:[NSArray arrayWithObject:sort] 
                       predicate:predicate];
}

- (NSArray *)medications {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO];
    return [self entriesWithType:HRMEntryTypeMedication
                 sortDescriptors:[NSArray arrayWithObject:sort]];
}

- (NSArray *)encounters {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    return [self entriesWithType:HRMEntryTypeEncounter
                 sortDescriptors:[NSArray arrayWithObject:sort]];
}

- (NSArray *)conditions {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO];
    return [self entriesWithType:HRMEntryTypeCondition
                 sortDescriptors:[NSArray arrayWithObject:sort]];
}

- (NSString *)initials {
    NSString *first = [[self.firstName substringToIndex:1] lowercaseString];
    NSString *last = [[self.lastName substringToIndex:1] lowercaseString];
    return [NSString stringWithFormat:@"%@%@", first, last];
}

@end
