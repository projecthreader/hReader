//
//  HRPatient.h
//  HReader
//
//  Created by Marshall Huss on 12/7/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HRAddress;

@interface HRPatient : NSObject

typedef enum {
    HRPatientGenderMale = 0,
    HRPatientGenderFemale = 1
} HRPatientGender;

@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) HRAddress *address;
@property (nonatomic) HRPatientGender gender;
@property (strong, nonatomic) NSDate *birthday;

- (id)initWithName:(NSString *)aName image:(UIImage *)aImage;

- (NSString *)genderAsString;
- (NSString *)age;
- (NSString *)dateOfBirthString;

@end
