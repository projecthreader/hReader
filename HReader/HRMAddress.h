//
//  HRMAddress.h
//  HReader
//
//  Created by Caleb Davenport on 2/7/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "GCManagedObject.h"

@class HRMPatient;

@interface HRMAddress : GCManagedObject

@property (nonatomic, retain) NSString *streetOne;
@property (nonatomic, retain) NSString *streetTwo;
@property (nonatomic, retain) NSString *attribute;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSString *zipCode;
@property (nonatomic, retain) HRMPatient *patient;

@end
