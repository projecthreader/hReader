//
//  HRMEntry.h
//  HReader
//
//  Created by Caleb Davenport on 2/9/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "CMDManagedObject.h"

#define DESCRIPTION_KEY @"description"
#define STATUS_KEY @"status"
#define TIME_KEY @"time"
#define START_TIME_KEY @"start_time"
#define END_TIME_KEY @"end_time"
#define CODES_KEY @"codes"
#define VALUE_KEY @"value"
#define DOSE_KEY @"dose"
#define REACTION_KEY @"reaction"
#define SEVERITY_KEY @"severity"
#define STATUS_KEY @"status"

//unsupported data keys
#define QUANTITY_KEY @"quantity"
#define DIRECTIONS_KEY @"directions"
#define PRESCRIBER_KEY @"prescriber"


typedef NS_ENUM(int, HRMEntryType) {
    HRMEntryTypeCondition,
    HRMEntryTypeAllergy,
    HRMEntryTypeEncounter,
    HRMEntryTypeMedication,
    HRMEntryTypeProcedure,
    HRMEntryTypeResult,
    HRMEntryTypeVitalSign,
    HRMEntryTypeImmunization
};

@class HRMPatient;
@class DDXMLElement;

@interface HRMEntry : CMDManagedObject

@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *reaction;
@property (nonatomic, retain) NSString *severity;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDictionary *value;
@property (nonatomic, retain) NSDictionary *codes;
@property (nonatomic, retain) NSDictionary *dose;
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, retain) HRMPatient *patient;

@property (nonatomic, retain) NSDictionary *patientComments;
@property (nonatomic, retain) NSString *comments;
@property (nonatomic, retain) NSNumber *userDeleted;

+ (HRMEntry *)instanceWithDictionary:(NSDictionary *)dictionary
                                type:(HRMEntryType)type
                           inContext:(NSManagedObjectContext *)context;

- (DDXMLElement *)timelineXMLElement DEPRECATED_ATTRIBUTE;

-(NSMutableAttributedString *)getDescAttributeString;

@end
