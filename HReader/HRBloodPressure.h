//
//  HRCholesterol.h
//  HReader
//
//  Created by Marshall Huss on 2/6/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HRVital.h"

@interface HRBloodPressure : HRVital

@property (nonatomic, assign) NSInteger systolic;
@property (nonatomic, assign) NSInteger diastolic;

@end
