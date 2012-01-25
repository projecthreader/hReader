//
//  HRMedication.m
//  HReader
//
//  Created by Marshall Huss on 1/25/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRMedication.h"

@implementation HRMedication

@synthesize drug    = __drug;
@synthesize dosage  = __dosage;

- (id)initWithDrug:(NSString *)drug dosage:(NSString  *)dosage {
    self = [super init];
    if (self) {
        self.drug = drug;
        self.dosage = dosage;
    }
    
    return self;
}

@end
