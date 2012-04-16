//
//  HRMPatient.m
//  HReader
//
//  Created by Caleb Davenport on 2/7/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRMPatient.h"
#import "HRMEntry.h"
#import "HRAppDelegate.h"

#import "DDXML.h"

static HRMPatient *selectedPatient = nil;

@interface HRMPatient ()

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

@dynamic immunizations;
@dynamic results;
@dynamic allergies;
@dynamic procedures;

@synthesize syntheticInfo = __syntheticInfo;
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

+ (NSArray *)patientsInContext:(NSManagedObjectContext *)context {
    static NSSortDescriptor *sort = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sort = [[NSSortDescriptor alloc] initWithKey:@"dateOfBirth" ascending:NO];
    });
    return [self allInContext:context sortDescriptor:sort];
}

+ (void)setSelectedPatient:(HRMPatient *)patient {
//    NSAssert([patient managedObjectContext] == [HRAppDelegate managedObjectContext], @"The global patient must exist in the main application context");
    selectedPatient = patient;
}

+ (HRMPatient *)selectedPatient {
    return selectedPatient;
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

- (void)setSyntheticInfo:(NSDictionary *)dictionary {
    __syntheticInfo = [dictionary copy];
    self.applets = [[dictionary objectForKey:@"applets"] mutableCopy];
}

#pragma mark - object methods

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

- (NSDictionary *)vitalSignsGroupedByDescription {
    
    // get vitals
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSArray *vitals = [self entriesWithType:HRMEntryTypeVitalSign
                            sortDescriptors:[NSArray arrayWithObject:sort]];
    
    // build grouped dictionary
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [vitals enumerateObjectsUsingBlock:^(HRMEntry *entry, NSUInteger idx, BOOL *stop) {
        NSString *desc = entry.desc;
        NSMutableArray *list = [dictionary objectForKey:desc];
        if (list == nil) {
            list = [NSMutableArray array];
            [dictionary setObject:list forKey:desc];
        }
        [list addObject:entry];
    }];
    
    // return
    return [dictionary autorelease];
    
}

- (NSArray *)vitalSignsWithEntryType:(NSString *)type {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"desc LIKE[c] %@", type];
    return [self entriesWithType:HRMEntryTypeVitalSign 
                 sortDescriptors:[NSArray arrayWithObject:sort] 
                       predicate:predicate];
}

- (NSArray *)medications {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    return [self entriesWithType:HRMEntryTypeMedication
                 sortDescriptors:[NSArray arrayWithObject:sort]];
}

- (NSArray *)encounters {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    return [self entriesWithType:HRMEntryTypeEncounter
                 sortDescriptors:[NSArray arrayWithObject:sort]];
}

- (NSArray *)conditions {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    return [self entriesWithType:HRMEntryTypeCondition
                 sortDescriptors:[NSArray arrayWithObject:sort]];
}

@end
