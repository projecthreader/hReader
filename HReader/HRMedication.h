//
//  HRMedication.h
//  HReader
//
//  Created by Marshall Huss on 1/25/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRMedication : NSObject

@property (copy, nonatomic) NSString *drug;
@property (copy, nonatomic) NSString *dosage;

- (id)initWithDrug:(NSString *)drug dosage:(NSString  *)dosage;

@end
