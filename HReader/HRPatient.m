//
//  HRPatient.m
//  HReader
//
//  Created by Marshall Huss on 12/7/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "HRPatient.h"

@implementation HRPatient

@synthesize name        = __name;
@synthesize image       = __image;;
@synthesize address     = __address;
@synthesize sex         = __sex;

- (void)dealloc {
    [__name release];
    [__image release];
    [__address release];
    
    [super dealloc];
}

- (id)initWithName:(NSString *)aName image:(UIImage *)aImage {
    self = [super init];
    if (self) {
        self.name = aName;
        self.image = aImage;
    }
    
    return self;
}

- (NSString *)sexAsString {
    switch (self.sex) {
        case HRPatientSexMale:
            return @"Male";
            break;
        case HRPatientSexFemale:
            return @"Female";
            break;
        case HRPatientSexTransgender:
            return @"Transgender";
            break;
        default:
            return @"Unknown";
            break;
    }
    return nil;
}

@end
