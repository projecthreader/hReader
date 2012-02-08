//
//  HRPatient.m
//  HReader
//
//  Created by Marshall Huss on 12/7/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "HRPatient.h"

@implementation HRPatient




@synthesize name            = __name;
@synthesize image           = __image;;
@synthesize address         = __address;
@synthesize gender          = __gender;
@synthesize birthday        = __birthday;
@synthesize placeOfBirth    = __placeOfBirth;
@synthesize race            = __race;
@synthesize ethnicity       = __ethnicity;
@synthesize phoneNumber     = __phoneNumber;

@synthesize encounters      = __encounters;

@synthesize info            = __info;

- (void)dealloc {
    [__info release];
    [__name release];
    [__image release];
    [__address release];
    [__birthday release];
    [__placeOfBirth release];
    [__race release];
    [__ethnicity release];
    [__phoneNumber release];
    
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

- (NSString *)genderAsString {
    switch (self.gender) {
        case HRPatientGenderMale:
            return @"Male";
            break;
        case HRPatientGenderFemale:
            return @"Female";
            break;
        default:
            return @"Unknown";
            break;
    }
    return nil;
}

- (NSString *)age {
    if (self.birthday) {
        NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:self.birthday];
        NSString *ageString = [NSString stringWithFormat:@"%.0f years", seconds/(60 * 60 * 24 * 365)];
        return ageString;
    } else {
        return @"-";
    }
}

- (NSString *)dateOfBirthString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMMM YYYY"];
    
    NSString *dobString = [formatter stringFromDate:self.birthday];
    [formatter release];
    
    return dobString;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<HRPatient #name: %@>", self.name];
}

@end
