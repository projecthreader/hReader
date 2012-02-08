//
//  HRPatient.h
//  HReader
//
//  Created by Marshall Huss on 12/7/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    HRPatientGenderMale = 0,
    HRPatientGenderFemale
} HRPatientGender;

@class HRAddress;

@interface HRPatient : NSObject

//@property (nonatomic, retain) NSString *firstName;
//@property (nonatomic, retain) NSString *lastName;
//@property (nonatomic, retain) NSString *compositeName;
//@property (nonatomic, retain) NSString *ethnicity;
//@property (nonatomic, retain) NSDate *dateOfBirth;
//@property (nonatomic, retain) NSString *race;
//@property (nonatomic, retain) NSNumber *gender;
//@property (nonatomic, retain) NSString *genderDescription;




@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) HRAddress *address;
@property (nonatomic) HRPatientGender gender;
@property (strong, nonatomic) NSDate *birthday;
@property (copy, nonatomic) NSString *placeOfBirth;
@property (copy, nonatomic) NSString *race;
@property (copy, nonatomic) NSString *ethnicity;
@property (copy, nonatomic) NSString *phoneNumber;

@property (strong, nonatomic) NSMutableArray *encounters;

@property (strong, nonatomic) NSMutableDictionary *info;

- (id)initWithName:(NSString *)aName image:(UIImage *)aImage;

- (NSString *)genderAsString;
- (NSString *)age;
- (NSString *)dateOfBirthString;

@end
