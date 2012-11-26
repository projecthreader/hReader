//
//  HRMEntry.h
//  HReader
//
//  Created by Caleb Davenport on 2/9/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "CMDManagedObject.h"

typedef enum {
    HRMEntryTypeCondition = 0,
    HRMEntryTypeAllergy,
    HRMEntryTypeEncounter,
    HRMEntryTypeMedication,
    HRMEntryTypeProcedure,
    HRMEntryTypeResult,
    HRMEntryTypeVitalSign,
    HRMEntryTypeImmunization
} HRMEntryType;

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

@property (nonatomic, retain) NSString *comments;

+ (HRMEntry *)instanceWithDictionary:(NSDictionary *)dictionary
                                type:(HRMEntryType)type
                           inContext:(NSManagedObjectContext *)context;

- (DDXMLElement *)timelineXMLElement;

@end
