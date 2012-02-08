//
//  HRMPatient.m
//  HReader
//
//  Created by Caleb Davenport on 2/7/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRMPatient.h"
#import "HRMAddress.h"
#import "HRMEncounter.h"

@implementation HRMPatient

@dynamic dateOfBirth;
@dynamic firstName;
@dynamic lastName;
@dynamic race;
@dynamic ethnicity;
@dynamic gender;
@dynamic compositeName;
@dynamic genderString;
@dynamic dateOfBirthString;
//@dynamic address;
//@dynamic encounters;

#pragma mark - parsers
+ (HRMPatient *)instanceWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
    HRMPatient *patient = [HRMPatient instanceInContext:context];
    patient.firstName = @"";
    patient.lastName = @"";
    patient.race = @"";
    patient.ethnicity = @"";
    // DOB
    // Genger
    return patient;
}

#pragma mark - attribute overrides
- (NSString *)compositeName {
    [self willAccessValueForKey:@"compositeName"];
    NSString *name = [NSString
                      stringWithFormat:@"%@ %@",
                      self.firstName,
                      self.lastName];
    [self didAccessValueForKey:@"compositeName"];
    return name;
}
- (NSString *)genderString {
    [self willAccessValueForKey:@"genderString"];
    NSString *gender = @"Unknown";
    if ([self.gender unsignedIntegerValue] == HRPatientGenderMale) {
        gender = @"Male";
    }
    else if ([self.gender unsignedIntegerValue] == HRPatientGenderFemale) {
        gender = @"Female";
    }
    [self didAccessValueForKey:@"genderString"];
    return gender;
}
- (NSString *)dateOfBirthString {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd MMMM YYYY"];
    });
    [self willAccessValueForKey:@"dateOfBirthString"];
    NSString *string = [formatter stringFromDate:self.dateOfBirth];
    [self didAccessValueForKey:@"dateOfBirthString"];
    return string;
}

@end
