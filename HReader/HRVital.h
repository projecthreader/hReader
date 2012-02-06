//
//  HRVital.h
//  HReader
//
//  Created by Marshall Huss on 2/6/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HRPatient.h"

@interface HRVital : NSObject

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *label;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) UIImage *graph;

@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) HRPatientGender gender;

- (BOOL)isNormal;
- (NSString *)resultString;
- (NSString *)normalString;
- (NSString *)label;

@end
