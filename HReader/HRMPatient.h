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
@class HRMTimelineEntry;

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
@property (nonatomic, retain) NSSet *timelineMedications;
@property (nonatomic, retain) NSSet *timelineRegimens;

#pragma mark - helper properties

/*
 
 Returns the first and last name concatenated.
 
 */
@property (nonatomic, readonly) NSString *compositeName;

/*
 
 Returns the first letter of both the first and last name, concatenated and
 uppercased.
 
 */
@property (nonatomic, readonly) NSString *initials;

/*
 
 Returns a pretty string that can be shown to the user based on the `gender`
 property.
 
 */
@property (nonatomic, readonly) NSString *genderString;

/*
 
 Returns a pretty string that can be shown to the user based on the 
 `relationship` and `gender` properties.
 
 */
@property (nonatomic, readonly) NSString *relationshipString;

/*
 
 Used by applets to determine which patient is currently being viewed without
 actually giving them the patient object. It is based on the server host and id.
 
 */
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
 
 Kick off a network sync. This method performs its work
 on a background thread and returns immediately.
 
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
- (DDXMLElement *)timelineXMLPayload DEPRECATED_ATTRIBUTE;

/*
 
 Generate the JSON document that is used to render the patient timeline. Use
 the `start` and `end` parameters to set a scope on the returned data.
 
 */
- (NSData *)timelineJSONPayloadWithStartDate:(NSDate *)start endDate:(NSDate *)end error:(NSError **)error;

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

- (void)addTimelineEntriesObject:(HRMTimelineEntry *)value;
- (void)removeTimelineEntriesObject:(HRMTimelineEntry *)value;
- (void)addTimelineEntries:(NSSet *)values;
- (void)removeTimelineEntries:(NSSet *)values;

@end
