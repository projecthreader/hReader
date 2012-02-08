//
//  HRMEncounter.h
//  HReader
//
//  Created by Caleb Davenport on 2/7/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "GCManagedObject.h"

@class HRMPatient;

@interface HRMEncounter : GCManagedObject

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) HRMPatient *patient;
// codes

//@property (nonatomic, retain) NSString * code;

@end
