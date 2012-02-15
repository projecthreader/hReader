//
//  HRMEntry.h
//  HReader
//
//  Created by Caleb Davenport on 2/9/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "GCManagedObject.h"

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

@interface HRMEntry : GCManagedObject

@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSDictionary *value;
@property (nonatomic, retain) NSDictionary *codes;
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, retain) HRMPatient *patient;

+ (HRMEntry *)instanceWithDictionary:(NSDictionary *)dictionary
                                type:(HRMEntryType)type
                           inContext:(NSManagedObjectContext *)context;

- (NSString *)timelineCategory;
- (NSString *)timelineDateAsString;

@end
