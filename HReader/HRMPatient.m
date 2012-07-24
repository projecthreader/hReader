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
#import "HRAPIClient.h"

#import "DDXML.h"

#if !__has_feature(objc_arc)
#error This class requires ARC
#endif

static NSString *HRMPatientSyncStatus = nil;
NSString * const HRMPatientSyncStatusDidChangeNotification = @"HRMPatientSyncStatusDidChange";

@interface HRMPatient ()

/*
 
 Fetch an array of entries belonging to the receiver sorted and filtered with
 the provided parameters.
 
 */
- (NSArray *)entriesWithType:(HRMEntryType)type sortDescriptor:(NSSortDescriptor *)sortDescriptor;
- (NSArray *)entriesWithType:(HRMEntryType)type sortDescriptor:(NSSortDescriptor *)sortDescriptor predicate:(NSPredicate *)predicate;

/*
 
 
 
 */
+ (void)setSyncStatus:(NSString *)status;

@end

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

#pragma mark - class methods

+ (id)instanceInContext:(NSManagedObjectContext *)context {
    HRMPatient *patient = [super instanceInContext:context];
    patient.displayOrder = [NSNumber numberWithLong:LONG_MAX];
    patient.relationship = [NSNumber numberWithShort:HRMPatientRelationshipOther];
    patient.gender = [NSNumber numberWithShort:HRMPatientGenderUnknown];
//    patient.applets = [NSArray array];
    patient.applets = [NSArray arrayWithObjects:@"org.mitre.hreader.medications", @"org.mitre.hreader.bloodpressure", nil];
    return patient;
}

+ (void)setSyncStatus:(NSString *)status {
    @synchronized(self) {
        NSLog(@"%@", status);
        HRMPatientSyncStatus = status;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:HRMPatientSyncStatusDidChangeNotification
         object:nil];
    }
}

+ (NSString *)syncStatus {
    @synchronized(self) {
        return HRMPatientSyncStatus;
    }
}

+ (void)performSync {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // log
        [self setSyncStatus:@"Starting sync…"];
        
        // get context
        NSManagedObjectContext *context = [HRAppDelegate managedObjectContext];
        
        // iterate over patients
        NSArray *patients = [self allInContext:context];
        NSUInteger count = [patients count];
        [patients enumerateObjectsUsingBlock:^(HRMPatient *obj, NSUInteger idx, BOOL *stop) {
            HRAPIClient *client = [HRAPIClient clientWithHost:obj.host];
            [client
             JSONForPatientWithIdentifier:obj.serverID
             startBlock:^{
                 [self setSyncStatus:[NSString stringWithFormat:@"Syncing %@…", [obj compositeName]]];
             }
             finishBlock:^(NSDictionary *payload) {
                 if (payload && ![obj isDeleted]) {
                     [obj populateWithContentsOfDictionary:payload];
                 }
                 else { NSLog(@"Unable to sync %@", [obj compositeName]); }
                 if (idx == (count - 1)) {
                     [context save:nil];
                     [self setSyncStatus:nil];
                 }
             }];
            
        }];
        
    });
}

#pragma mark - attribute overrides

- (NSString *)compositeName {
    [self willAccessValueForKey:@"compositeName"];
    NSString *name = [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    [self didAccessValueForKey:@"compositeName"];
    return name;
}

- (NSString *)initials {
    [self willAccessValueForKey:NSStringFromSelector(_cmd)];
    NSString *first = [[self.firstName substringToIndex:1] uppercaseString];
    NSString *last = [[self.lastName substringToIndex:1] uppercaseString];
    NSString *initials = [NSString stringWithFormat:@"%@%@", first, last];
    [self didAccessValueForKey:NSStringFromSelector(_cmd)];
    return initials;
}

- (NSString *)genderString {
    [self willAccessValueForKey:NSStringFromSelector(_cmd)];
    NSUInteger value = [self.gender shortValue];
    NSString *string = @"Unknown";
    if (value == HRMPatientGenderMale) { string = @"Male"; }
    else if (value == HRMPatientGenderFemale) { string = @"Female"; }
    [self didAccessValueForKey:NSStringFromSelector(_cmd)];
    return string;
}

- (NSString *)relationshipString {
    [self willAccessValueForKey:NSStringFromSelector(_cmd)];
    NSUInteger value = [self.relationship shortValue];
    NSString *string = @"Other";
    if (value == HRMPatientRelationshipMe) { string = @"Me"; }
    else if (value == HRMPatientRelationshipSpouse) {
        string = @"Spouse";
        short value = [self.gender shortValue];
        if (value == HRMPatientGenderMale) { string = @"Husband"; }
        else if (value == HRMPatientGenderFemale) { string = @"Wife"; }
    }
    else if (value == HRMPatientRelationshipChild) {
        string = @"Child";
        short value = [self.gender shortValue];
        if (value == HRMPatientGenderMale) { string = @"Son"; }
        else if (value == HRMPatientGenderFemale) { string = @"Daughter"; }
    }
    else if (value == HRMPatientRelationshipFamily) { string = @"Family"; }
    [self didAccessValueForKey:NSStringFromSelector(_cmd)];
    return string;
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"desc LIKE[cd] %@", type];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    return [self entriesWithType:HRMEntryTypeVitalSign sortDescriptor:sort predicate:predicate];
}

- (NSArray *)entriesWithType:(HRMEntryType)type sortDescriptor:(NSSortDescriptor *)sortDescriptor {
    return [self entriesWithType:type sortDescriptor:sortDescriptor predicate:nil];
}

- (NSArray *)entriesWithType:(HRMEntryType)type sortDescriptor:(NSSortDescriptor *)sortDescriptor predicate:(NSPredicate *)predicate {
    NSPredicate *typePredicate = [NSPredicate predicateWithFormat:@"type == %@", [NSNumber numberWithShort:type]];
    NSPredicate *patientPredicate = [NSPredicate predicateWithFormat:@"patient == %@", self];
    NSMutableArray *predicates = [NSMutableArray arrayWithObjects:typePredicate, patientPredicate, nil];
    if (predicate) { [predicates addObject:predicate]; }
    NSPredicate *andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    return [HRMEntry
            allInContext:[self managedObjectContext]
            withPredicate:andPredicate
            sortDescriptor:sortDescriptor];
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
        if ([object isEqualToString:@"M"]) { self.gender = [NSNumber numberWithShort:HRMPatientGenderMale]; }
        else if ([object isEqualToString:@"F"]) { self.gender = [NSNumber numberWithShort:HRMPatientGenderFemale]; }
        else { self.gender = [NSNumber numberWithShort:HRMPatientGenderUnknown]; }
    }
    else { self.gender = [NSNumber numberWithShort:HRMPatientGenderUnknown]; }
    
    // objects conforming to the "entry" type
    [self removeEntries:self.entries];
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
    
}

- (UIImage *)patientImage {
    return [UIImage imageNamed:[NSString stringWithFormat:@"UserImage-%@", self.serverID]];
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

@end
