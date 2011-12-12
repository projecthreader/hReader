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
    HRPatientSexMale = 0,
    HRPatientSexFemale = 1,
    HRPatientSexTransgender = 2
} HRPatientSex;

@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) HRAddress *address;
@property (nonatomic) HRPatientSex sex;
@property (strong, nonatomic) NSDate *birthday;

- (id)initWithName:(NSString *)aName image:(UIImage *)aImage;

- (NSString *)sexAsString;
- (NSString *)age;

@end
