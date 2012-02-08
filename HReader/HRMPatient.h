//
//  HRMPatient.h
//  HReader
//
//  Created by Caleb Davenport on 2/7/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "GCManagedObject.h"

#import "HRManagedObject.h"

typedef enum {
    HRPatientGenderMale = 0,
    HRPatientGenderFemale
} HRPatientGender;

@class HRMAddress;
@class HRMEncounter;

@interface HRMPatient : GCManagedObject <HRManagedObject>

@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *compositeName;
@property (nonatomic, retain) NSString *race;
@property (nonatomic, retain) NSString *ethnicity;
@property (nonatomic, retain) NSNumber *gender;
@property (nonatomic, retain) NSString *genderString;
@property (nonatomic, retain) NSDate *dateOfBirth;
@property (nonatomic, retain) NSString *dateOfBirthString;
@property (nonatomic, retain) NSSet *encounters;

//@property (nonatomic, retain) HRMAddress *address;


@end

@interface HRMPatient (CoreDataGeneratedAccessors)

- (void)addEncountersObject:(HRMEncounter *)value;
- (void)removeEncountersObject:(HRMEncounter *)value;
- (void)addEncounters:(NSSet *)values;
- (void)removeEncounters:(NSSet *)values;

@end
