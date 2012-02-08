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
@dynamic encounters;

#pragma mark - parsers
+ (id)instanceWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
    
    // vars
    id object = nil;
    Class class = [NSNull class];
    
    // create patient
    HRMPatient *patient = [HRMPatient instanceInContext:context];
    
    // load basic data
    object = [dictionary objectForKey:@"first"];
    if (object && ![object isKindOfClass:class]) {
        patient.firstName = object;
    }
    object = [dictionary objectForKey:@"last"];
    if (object && ![object isKindOfClass:class]) {
        patient.lastName = object;
    }
    object = [dictionary objectForKey:@"race"];
    if (object && ![object isKindOfClass:class]) {
        patient.race = object;
    }
    object = [dictionary objectForKey:@"ethnicity"];
    if (object && ![object isKindOfClass:class]) {
        patient.ethnicity = object;
    }
    object = [dictionary objectForKey:@"birthdate"];
    if (object && ![object isKindOfClass:class]) {
        NSTimeInterval stamp = [object doubleValue];
        patient.dateOfBirth = [NSDate dateWithTimeIntervalSince1970:stamp];
    }
    object = [dictionary objectForKey:@"gender"];
    if (object && ![object isKindOfClass:class]) {
        if ([object isEqualToString:@"M"]) {
            patient.gender = [NSNumber numberWithUnsignedInteger:HRPatientGenderMale];
        }
        else if ([object isEqualToString:@"F"]) {
            patient.gender = [NSNumber numberWithUnsignedInteger:HRPatientGenderFemale];
        }
    }
    
    // encounters
    object = [dictionary objectForKey:@"encounters"];
    [object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        HRMEncounter *encounter = [HRMEncounter instanceWithDictionary:obj inContext:context];
        [patient addEncountersObject:encounter];
    }];
    
    // return
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
