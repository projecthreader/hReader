//
//  HRMTimelineEntry.h
//  HReader
//
//  Created by Caleb Davenport on 12/13/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "CMDManagedObject.h"

typedef NS_ENUM(unsigned int, HRMTimelineEntryType) {
    HRMTimelineEntryTypeLevels,
    HRMTimelineEntryTypeMedication,
    HRMTimelineEntryTypeRegimen
};

@class HRMPatient;

@interface HRMTimelineEntry : CMDManagedObject

@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, retain) HRMPatient *patient;

@end
