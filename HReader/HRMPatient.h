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

#pragma mark - core data properties

@property (nonatomic, retain) NSString *mongoID;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *compositeName;
@property (nonatomic, retain) NSString *race;
@property (nonatomic, retain) NSString *ethnicity;
@property (nonatomic, retain) NSNumber *gender;
@property (nonatomic, retain) NSString *genderString;
@property (nonatomic, retain) NSDate *dateOfBirth;
@property (nonatomic, retain) NSSet *entries;
@property (nonatomic, retain) NSDictionary *syntheticInfo;

#pragma mark - fetched properties

@property (nonatomic, readonly) NSArray *conditions;
@property (nonatomic, readonly) NSArray *encounters;
@property (nonatomic, readonly) NSArray *medications;

#pragma mark - other properties

@property (nonatomic, retain) NSArray *allergies;
@property (nonatomic, retain) NSArray *immunizations;
@property (nonatomic, retain) NSArray *procedures;
@property (nonatomic, retain) NSArray *results;
@property (nonatomic, retain) NSMutableArray *applets;

#pragma mark - instance methods

/*
 
 Generate the XML document that is used to render the patient timeline.
 
 */
- (DDXMLElement *)timelineXMLDocument;

/*
 
 Load all entries that have the type set to HRMEntryTypeVitalSign and match the
 given type. These entries will be sorted by date ascending.
 
 */
- (NSArray *)vitalSignsWithType:(NSString *)type;

/*
 
 These methods load simulated data from the application bundle.
 
 */
- (UIImage *)patientImage;
- (NSURL *)C32HTMLURL;

/*
 
 Get the patient initials. If the receiver's name is "Jon Doe" then this method
 will return "jd".
 
 */
- (NSString *)initials;

#pragma mark - class methods

/*
 
 Returns a new patient object that is populated with data from the given
 dictionary inserted into the given context. The format of the dictionary must
 conform to the hData standard.
 
 */
+ (HRMPatient *)instanceWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context;

@end

@interface HRMPatient (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(HRMEntry *)value;
- (void)removeEntriesObject:(HRMEntry *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

@end
