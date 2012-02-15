//
//  HRMPatient.h
//  HReader
//
//  Created by Caleb Davenport on 2/7/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "GCManagedObject.h"

typedef enum {
    HRPatientGenderMale = 0,
    HRPatientGenderFemale
} HRPatientGender;

@class HRMEntry;

@interface HRMPatient : GCManagedObject

@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *compositeName;
@property (nonatomic, retain) NSString *race;
@property (nonatomic, retain) NSString *ethnicity;
@property (nonatomic, retain) NSNumber *gender;
@property (nonatomic, retain) NSString *genderString;
@property (nonatomic, retain) NSDate *dateOfBirth;
@property (nonatomic, retain) NSString *dateOfBirthString;
@property (nonatomic, retain) NSSet *entries;

@property (nonatomic, retain) NSArray *encounters;
@property (nonatomic, retain) NSArray *allergies;
@property (nonatomic, retain) NSArray *immunizations;
@property (nonatomic, retain) NSArray *conditions;
@property (nonatomic, retain) NSArray *procedures;
@property (nonatomic, retain) NSArray *results;
@property (nonatomic, retain) NSArray *vitalSigns;
@property (nonatomic, retain) NSArray *medications;

+ (HRMPatient *)instanceWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context;
+ (NSArray *)patientsInContext:(NSManagedObjectContext *)context;

@end

@interface HRMPatient (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(HRMEntry *)value;
- (void)removeEntriesObject:(HRMEntry *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

@end
