//
//  HRMEncounter.h
//  HReader
//
//  Created by Caleb Davenport on 2/7/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "GCManagedObject.h"

#import "HRManagedObject.h"

@class HRMPatient;

@interface HRMEncounter : GCManagedObject <HRManagedObject>

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) HRMPatient *patient;
@property (nonatomic, retain) NSDictionary *codes;

@end
