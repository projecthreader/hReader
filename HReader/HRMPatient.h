//
//  HRMPatient.h
//  HReader
//
//  Created by Caleb Davenport on 2/7/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "GCManagedObject.h"

typedef enum {
    HRMPatientGenderMale = 0,
    HRMPatientGenderFemale
} HRMPatientGender;

@class HRMEntry;
@class DDXMLElement;

@interface HRMPatient : GCManagedObject

@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *compositeName;
@property (nonatomic, retain) NSString *race;
@property (nonatomic, retain) NSString *ethnicity;
@property (nonatomic, retain) NSNumber *gender;
@property (nonatomic, retain) NSString *genderString;
@property (nonatomic, retain) NSDate *dateOfBirth;
@property (nonatomic, retain) NSSet *entries;

@property (nonatomic, retain) NSArray *encounters;
@property (nonatomic, retain) NSArray *allergies;
@property (nonatomic, retain) NSArray *immunizations;
@property (nonatomic, retain) NSArray *conditions;
@property (nonatomic, retain) NSArray *procedures;
@property (nonatomic, retain) NSArray *results;
@property (nonatomic, retain) NSArray *vitalSigns;
@property (nonatomic, retain) NSArray *medications;

// get a new patient with json dictionary
+ (HRMPatient *)instanceWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context;

// get list of patients from persistent store
+ (NSArray *)patientsInContext:(NSManagedObjectContext *)context;

// deal with current selection
+ (void)setSelectedPatient:(HRMPatient *)patient;
+ (HRMPatient *)selectedPatient;

// get fake data
- (DDXMLElement *)timelineXMLDocument;
- (UIImage *)patientImage;
- (NSURL *)C32HTMLURL;

// vital signs
- (NSDictionary *)vitalSignsGroupedByDescription;

@end

@interface HRMPatient (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(HRMEntry *)value;
- (void)removeEntriesObject:(HRMEntry *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

@end
