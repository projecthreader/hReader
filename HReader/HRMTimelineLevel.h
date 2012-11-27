//
//  HRTimelineLevel.h
//  HReader
//
//  Created by Caleb Davenport on 11/27/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "CMDManagedObject.h"

@class HRMPatient;

@interface HRMTimelineLevel : CMDManagedObject

@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain) HRMPatient *patient;
@property (nonatomic, retain) NSDate *createdAt;

@end
