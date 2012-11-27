//
//  HRMPatient.h
//  HReader
//
//  Created by Caleb Davenport on 2/7/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "CMDManagedObject.h"

typedef NS_ENUM(short, HRMPatientGender) {
    HRMPatientGenderMale,
    HRMPatientGenderFemale,
    HRMPatientGenderUnknown
};

typedef NS_ENUM(short, HRMPatientRelationship) {
    HRMPatientRelationshipMe,
    HRMPatientRelationshipSpouse,
    HRMPatientRelationshipChild,
    HRMPatientRelationshipFamily,
    HRMPatientRelationshipOther
};

extern NSString * const HRMPatientSyncStatusDidChangeNotification;

@class HRMEntry;
@class DDXMLElement;
@class HRMTimelineLevel;

@interface HRMPatient : CMDManagedObject

#pragma mark - core data properties

@property (nonatomic, retain) NSString *serverID;
@property (nonatomic, retain) NSString *host;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *race;
@property (nonatomic, retain) NSString *ethnicity;
@property (nonatomic, retain) NSNumber *gender;
@property (nonatomic, retain) NSDate *dateOfBirth;
@property (nonatomic, retain) NSSet *entries;
@property (nonatomic, retain) NSDictionary *syntheticInfo;
@property (nonatomic, retain) NSArray *applets;
@property (nonatomic, retain) NSNumber *displayOrder;
@property (nonatomic, retain) NSNumber *relationship;
@property (nonatomic, retain) NSSet *timelineLevels;

#pragma mark - transient properties

@property (nonatomic, readonly) NSString *compositeName;
@property (nonatomic, readonly) NSString *initials;
@property (nonatomic, readonly) NSString *genderString;
@property (nonatomic, readonly) NSString *relationshipString;
@property (nonatomic, readonly) NSString *identityToken;

#pragma mark - fetched properties

@property (nonatomic, readonly) NSArray *conditions;
@property (nonatomic, readonly) NSArray *encounters;
@property (nonatomic, readonly) NSArray *medications;
@property (nonatomic, readonly) NSArray *immunizations;
@property (nonatomic, readonly) NSArray *allergies;
@property (nonatomic, readonly) NSArray *procedures;
@property (nonatomic, readonly) NSArray *results;

#pragma mark - class methods

/*
 
 
 
 */
+ (void)performSync;

#pragma mark - object methods

/*
 
 Clear all server generated data from the instance and repopulate with data
 from the given JSON payload. This extends to all "entry" subitems.
 
 */
- (void)populateWithContentsOfDictionary:(NSDictionary *)dictionary;

/*
 
 Generate the XML document that is used to render the patient timeline.
 
 */
- (DDXMLElement *)timelineXMLPayload;

/*
 
 
 
 */
- (NSData *)timelineJSONPayloadWithPredicate:(NSPredicate *)predicate error:(NSError **)error;

/*
 
 Load all entries that have the type set to HRMEntryTypeVitalSign and match the
 given type. These entries will be sorted by date ascending.
 
 */
- (NSArray *)vitalSignsWithType:(NSString *)type;

/*
 
 Fetch certain types of data from the entries collection.
 
 */
- (NSArray *)totalCholesterol;

/*
 
 These methods load simulated data from the application bundle.
 
 */
- (UIImage *)patientImage;
- (NSURL *)C32HTMLURL;

@end

@interface HRMPatient (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(HRMEntry *)value;
- (void)removeEntriesObject:(HRMEntry *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

- (void)addTimelineLevelsObject:(HRMTimelineLevel *)value;
- (void)removeTimelineLevelsObject:(HRMTimelineLevel *)value;
- (void)addTimelineLevels:(NSSet *)values;
- (void)removeTimelineLevels:(NSSet *)values;

@end
