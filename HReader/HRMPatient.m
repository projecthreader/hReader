//
//  HRMPatient.m
//  HReader
//
//  Created by Caleb Davenport on 2/7/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "HRMPatient.h"
#import "HRMEntry.h"
#import "HRMTimelineLevel.h"

#import "HRAppDelegate.h"
#import "HRAPIClient.h"
#import "HRCryptoManager.h"

#import "DDXML.h"

NSString * const HRMPatientSyncStatusDidChangeNotification = @"HRMPatientSyncStatusDidChange";

@implementation HRMPatient

@dynamic serverID;
@dynamic host;
@dynamic dateOfBirth;
@dynamic firstName;
@dynamic lastName;
@dynamic race;
@dynamic ethnicity;
@dynamic gender;
@dynamic entries;
@dynamic syntheticInfo;
@dynamic applets;
@dynamic displayOrder;
@dynamic relationship;
@dynamic timelineLevels;

@synthesize identityToken = _identityToken;

#pragma mark - class methods

+ (id)instanceInContext:(NSManagedObjectContext *)context {
    HRMPatient *patient = [super instanceInContext:context];
    patient.displayOrder = @(LONG_MAX);
    patient.relationship = @(HRMPatientRelationshipOther);
    patient.gender = @(HRMPatientGenderUnknown);
    patient.applets = @[ @"org.mitre.hreader.medications", @"org.mitre.hreader.bloodpressure" ];
    return patient;
}

+ (void)performSync {
    NSManagedObjectContext *context = [HRAppDelegate managedObjectContext];
    [context performBlock:^{
        NSArray *patients = [self allInContext:context];
        [patients enumerateObjectsUsingBlock:^(HRMPatient *patient, NSUInteger idx, BOOL *stop) {
            HRAPIClient *client = [HRAPIClient clientWithHost:patient.host];
            [client
             JSONForPatientWithIdentifier:patient.serverID
             startBlock:nil
             finishBlock:^(NSDictionary *payload) {
                 if (![patient isDeleted]) {
                     if (payload) {
                         [patient populateWithContentsOfDictionary:payload];
                         NSError *error = nil;
                         if (![context save:&error]) {
                             NSLog(@"Unable to save changes to %@. %@", patient.compositeName, error);
                         }
                     }
                     else { NSLog(@"Unable to sync %@", patient.compositeName); }
                 }
             }];
        }];
    }];
}

+ (NSString *)modelName {
    return @"Patient";
}

#pragma mark - attribute overrides

- (NSString *)identityToken {
    if (_identityToken == nil) {
        NSMutableString *token = [NSMutableString string];
        NSString *identity = [NSString stringWithFormat:@"%@%@", self.host, self.serverID];
        NSData *identityData = [identity dataUsingEncoding:NSUTF8StringEncoding];
        unsigned char *buffer = malloc(CC_MD5_DIGEST_LENGTH);
        CC_MD5([identityData bytes], [identityData length], buffer);
        XOR(236, buffer, CC_MD5_DIGEST_LENGTH);
        for (NSUInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
            [token appendFormat:@"%02x", (unsigned int)buffer[i]];
        }
        free(buffer);
        _identityToken = [token copy];
    }
    return _identityToken;
}

- (NSString *)compositeName {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

- (NSString *)initials {
    NSString *first = [[self.firstName substringToIndex:1] uppercaseString];
    NSString *last = [[self.lastName substringToIndex:1] uppercaseString];
    return [NSString stringWithFormat:@"%@%@", first, last];
}

- (NSString *)genderString {
    short value = [self.gender shortValue];
    if (value == HRMPatientGenderMale) { return @"Male"; }
    else if (value == HRMPatientGenderFemale) { return @"Female"; }
    return @"Unknown";
}

- (NSString *)relationshipString {
    short relationship = [self.relationship shortValue];
    if (relationship == HRMPatientRelationshipMe) { return @"Me"; }
    else if (relationship == HRMPatientRelationshipSpouse) {
        short gender = [self.gender shortValue];
        if (gender == HRMPatientGenderMale) { return @"Husband"; }
        else if (gender == HRMPatientGenderFemale) { return @"Wife"; }
        return @"Spouse";
    }
    else if (relationship == HRMPatientRelationshipChild) {
        short gender = [self.gender shortValue];
        if (gender == HRMPatientGenderMale) { return @"Son"; }
        else if (gender == HRMPatientGenderFemale) { return @"Daughter"; }
        return @"Child";
    }
    else if (relationship == HRMPatientRelationshipFamily) { return @"Family"; }
    return @"Other";
}

#pragma mark - fetch entries

- (NSArray *)medications {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO];
    return [self entriesWithType:HRMEntryTypeMedication sortDescriptor:sort];
}

- (NSArray *)encounters {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    return [self entriesWithType:HRMEntryTypeEncounter sortDescriptor:sort];
}

- (NSArray *)conditions {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO];
    return [self entriesWithType:HRMEntryTypeCondition sortDescriptor:sort];
}

- (NSArray *)immunizations {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    return [self entriesWithType:HRMEntryTypeImmunization sortDescriptor:sort];
}

- (NSArray *)procedures {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    return [self entriesWithType:HRMEntryTypeProcedure sortDescriptor:sort];
}

- (NSArray *)allergies {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO];
    return [self entriesWithType:HRMEntryTypeAllergy sortDescriptor:sort];
}

- (NSArray *)results {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO];
    return [self entriesWithType:HRMEntryTypeResult sortDescriptor:sort];
}

- (NSArray *)vitalSignsWithType:(NSString *)type {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"desc CONTAINS[cd] %@", type];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    return [self entriesWithType:HRMEntryTypeVitalSign sortDescriptor:sort predicate:predicate];
}

- (NSArray *)entriesWithType:(HRMEntryType)type sortDescriptor:(NSSortDescriptor *)sortDescriptor {
    return [self entriesWithType:type sortDescriptor:sortDescriptor predicate:nil];
}

- (NSArray *)entriesWithType:(HRMEntryType)type sortDescriptor:(NSSortDescriptor *)sortDescriptor predicate:(NSPredicate *)predicate {
    NSPredicate *typePredicate = [NSPredicate predicateWithFormat:@"type == %@", @(type)];
    NSPredicate *patientPredicate = [NSPredicate predicateWithFormat:@"patient == %@", self];
    NSMutableArray *predicates = [NSMutableArray arrayWithObjects:typePredicate, patientPredicate, nil];
    if (predicate) { [predicates addObject:predicate]; }
    NSPredicate *andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    return [HRMEntry
            allInContext:[self managedObjectContext]
            predicate:andPredicate
            sortDescriptor:sortDescriptor];
}

- (NSArray *)totalCholesterol {
    NSPredicate *typePredicate = [NSPredicate predicateWithFormat:@"type == %@", @(HRMEntryTypeResult)];
    NSPredicate *patientPredicate = [NSPredicate predicateWithFormat:@"patient == %@", self];
    NSArray *predicates = @[ typePredicate, patientPredicate ];
    NSPredicate *andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    return [self entriesWithType:HRMEntryTypeResult sortDescriptor:sort predicate:andPredicate];
}

#pragma mark - object methods

- (void)populateWithContentsOfDictionary:(NSDictionary *)dictionary {
    
    // store placeholder objects
    id __block object = nil;
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // first name
    object = [dictionary objectForKey:@"first"];
    if (object && [object isKindOfClass:[NSString class]]) { self.firstName = object; }
    else { self.firstName = nil; }
    
    // last name
    object = [dictionary objectForKey:@"last"];
    if (object && [object isKindOfClass:[NSString class]]) { self.lastName = object; }
    else { self.lastName = nil; }
    
    // race
    object = [dictionary objectForKey:@"race"];
    if (object && [object isKindOfClass:[NSString class]]) { self.race = object; }
    else { self.race = nil; }
    
    // ethnicity
    object = [dictionary objectForKey:@"ethnicity"];
    if (object && [object isKindOfClass:[NSString class]]) { self.ethnicity = object; }
    else { self.ethnicity = nil; }
    
    // birthdate
    object = [dictionary objectForKey:@"birthdate"];
    if (object && [object isKindOfClass:[NSNumber class]]) {
        NSTimeInterval interval = [object doubleValue];
        self.dateOfBirth = [NSDate dateWithTimeIntervalSince1970:interval];
    }
    else { self.dateOfBirth = nil; }
    
    // gender
    object = [dictionary objectForKey:@"gender"];
    if (object && [object isKindOfClass:[NSString class]]) {
        if ([object isEqualToString:@"M"]) { self.gender = @(HRMPatientGenderMale); }
        else if ([object isEqualToString:@"F"]) { self.gender = @(HRMPatientGenderFemale); }
        else { self.gender = @(HRMPatientGenderUnknown); }
    }
    else { self.gender = @(HRMPatientGenderUnknown); }
    
    // objects conforming to the "entry" type
    [self.entries enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [context deleteObject:obj];
    }];
    void (^collectionBlock) (HRMEntryType, NSString *) = ^(HRMEntryType type, NSString *key) {
        object = [dictionary objectForKey:key];
        if (object && [object isKindOfClass:[NSArray class]]) {
            [object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                    HRMEntry *entry = [HRMEntry instanceWithDictionary:obj type:type inContext:context];
                    [self addEntriesObject:entry];
                }
            }];
        }
    };
    collectionBlock(HRMEntryTypeEncounter, @"encounters");
    collectionBlock(HRMEntryTypeCondition, @"conditions");
    collectionBlock(HRMEntryTypeAllergy, @"allergies");
    collectionBlock(HRMEntryTypeMedication, @"medications");
    collectionBlock(HRMEntryTypeProcedure, @"procedures");
    collectionBlock(HRMEntryTypeResult, @"results");
    collectionBlock(HRMEntryTypeVitalSign, @"vital_signs");
    collectionBlock(HRMEntryTypeImmunization, @"immunizations");
    
    // if we are a new object, try loading sample data
    if ([[self objectID] isTemporaryID]) {
        NSURL *URL;
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *resource;
        NSString *initials = [self.initials lowercaseString];
        
        // applets
        resource = [NSString stringWithFormat:@"applets-%@", initials];
        URL = [bundle URLForResource:resource withExtension:@"plist"];
        if (URL) {
            self.applets = [NSArray arrayWithContentsOfURL:URL];
        }
        
    }
    
}

- (UIImage *)patientImage {
    return [UIImage imageNamed:[NSString stringWithFormat:@"UserImage-%@", self.serverID]];
}

- (DDXMLElement *)timelineXMLPayload {
    
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

- (NSData *)timelineJSONPayloadWithPredicate:(NSPredicate *)predicate error:(NSError **)error {

    // type
    static NSDictionary *types = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        types = @{
            @(HRMEntryTypeAllergy) : @"allergies",
            @(HRMEntryTypeCondition) : @"conditions",
            @(HRMEntryTypeResult) : @"results",
            @(HRMEntryTypeEncounter) : @"encounters",
            @(HRMEntryTypeVitalSign) : @"vitals",
            @(HRMEntryTypeImmunization) : @"immunizations",
            @(HRMEntryTypeMedication) : @"medications",
            @(HRMEntryTypeProcedure) : @"procedures"
        };
    });
    
    // gather entries
    NSMutableArray *predicates = [NSMutableArray array];
    [predicates addObject:[NSPredicate predicateWithFormat:@"patient = %@", self]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"type != %@", @(HRMEntryTypeVitalSign)]];
    if (predicate) { [predicates addObject:predicate]; }
    NSArray *entries = [HRMEntry
                        allInContext:[self managedObjectContext]
                        predicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]
                        sortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [entries enumerateObjectsUsingBlock:^(HRMEntry *entry, NSUInteger idx, BOOL *stop) {
        
        // get scalar
        NSDictionary *value = entry.value;
        id scalar = [value objectForKey:@"scalar"];
        if ([scalar respondsToSelector:@selector(floatValue)]) {
            scalar = @([scalar floatValue]);
        }
        
        // get target array
        NSString *type = [types objectForKey:entry.type];
        NSMutableArray *array = [dictionary objectForKey:type];
        if (array == nil) {
            array = [NSMutableArray array];
            [dictionary setObject:array forKey:type];
        }
        
        // get date
        NSDate *date = nil;
        if (entry.date)             { date = entry.date; }
        else if (entry.startDate)   { date = entry.startDate; }
        else if (entry.endDate)     { date = entry.endDate; }
        
        // build payload
        NSDictionary *dictionary = @{
            @"type" : ([types objectForKey:entry.type] ?: @"unkonwn"),
            @"description" : (entry.desc ?: [NSNull null]),
            @"date" : @([date timeIntervalSince1970]),
            @"measurement" : @{
                @"value" : (scalar ?: [NSNull null]),
                @"unit" : ([value objectForKey:@"units"] ?: [NSNull null])
            }
        };
        
        // save
        [array addObject:dictionary];
        
    }];
    
    // build json data
    dictionary[@"levels"] = [self timelineLevelsGroupedByTypeWithPredicate:predicate];
    dictionary[@"vitals"] = [self timelineVitalsCategorizedByDescriptionWithPredicate:predicate];
    return [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:error];
    
}

- (NSDictionary *)timelineLevelsGroupedByTypeWithPredicate:(NSPredicate *)predicate {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSMutableArray *predicates = [NSMutableArray array];
    [predicates addObject:[NSPredicate predicateWithFormat:@"patient = %@", self]];
    if (predicate) { [predicates addObject:predicate]; }
    NSArray *levels = [HRMTimelineLevel
                       allInContext:[self managedObjectContext]
                       predicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]
                       sortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    return dictionary;
}

- (NSArray *)timelineVitalsCategorizedByDescriptionWithPredicate:(NSPredicate *)predicate {
    
    // gather vitals
    NSMutableDictionary *vitals = [NSMutableDictionary dictionary];
    NSMutableArray *predicates = [NSMutableArray array];
    [predicates addObject:[NSPredicate predicateWithFormat:@"type = %@", @(HRMEntryTypeVitalSign)]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"patient = %@", self]];
    if (predicate) { [predicates addObject:predicate]; }
    NSArray *entries = [HRMEntry
                        allInContext:[self managedObjectContext]
                        predicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]
                        sortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    [entries enumerateObjectsUsingBlock:^(HRMEntry *entry, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *value = entry.value;
        id scalar = [value objectForKey:@"scalar"];
        if ([scalar respondsToSelector:@selector(integerValue)]) {
            scalar = @([scalar integerValue]);
        }
        
        // get target collection
        NSString *description = entry.desc;
        NSDictionary *wrapper = [vitals objectForKey:description];
        if (wrapper == nil) {
            wrapper = @{
                @"description" : description,
                @"values" : [NSMutableArray array],
                @"units" : ([value objectForKey:@"units"] ?: [NSNull null])
            };
            [vitals setObject:wrapper forKey:description];
        }
        NSMutableArray *values = [wrapper objectForKey:@"values"];
        if (scalar) { [values addObject:scalar]; }
        
    }];
    
    // sort and group blood pressure
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
    NSMutableArray *wrappers = [[vitals allValues] mutableCopy];
    NSIndexSet *set = [wrappers indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *description = [obj objectForKey:@"description"];
        return (BOOL)([description rangeOfString:@"blood pressure" options:NSCaseInsensitiveSearch].location != NSNotFound);
    }];
    NSArray *bloodPressure = [wrappers objectsAtIndexes:set];
    bloodPressure = [bloodPressure hr_sortedArrayUsingKey:@"description" ascending:NO];
    [wrappers removeObjectsAtIndexes:set];
    [wrappers sortUsingDescriptors:@[ sort ]];
    [wrappers addObject:bloodPressure];
    wrappers = (id)[wrappers hr_flatten];
    return wrappers;
    
}

- (NSURL *)C32HTMLURL {
    NSString *string = [NSString stringWithFormat:@"C32-%@-%@", self.lastName, self.firstName];
    return [[NSBundle mainBundle] URLForResource:string withExtension:@"html"];
}

@end
