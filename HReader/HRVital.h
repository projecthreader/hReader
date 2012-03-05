//
//  HRVital.h
//  HReader
//
//  Created by Marshall Huss on 2/6/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HRMEntry.h"

@interface HRVital : NSObject

@property (nonatomic, readonly, copy) NSArray *entries;

@property (readonly, nonatomic) NSString *title;
@property (readonly, nonatomic) NSDate *date;
@property (readonly, nonatomic, getter = isNormal) BOOL normal;

@property (readonly, nonatomic) NSString *leftTitle;
@property (readonly, nonatomic) NSString *leftValue;
@property (readonly, nonatomic) NSString *leftUnit;

@property (readonly, nonatomic) NSString *rightTitle;
@property (readonly, nonatomic) NSString *rightValue;

@property (readonly, nonatomic) double value;

@property (readonly, nonatomic) double normalLow;
@property (readonly, nonatomic) double normalHigh;

- (id)initWithEntries:(NSArray *)entries;

@end
