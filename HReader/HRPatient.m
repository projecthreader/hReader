//
//  HRPatient.m
//  HReader
//
//  Created by Marshall Huss on 12/7/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "HRPatient.h"

@implementation HRPatient

@synthesize name;
@synthesize image;

- (id)initWithName:(NSString *)aName image:(UIImage *)aImage {
    self = [super init];
    if (self) {
        self.name = aName;
        self.image = aImage;
    }
    
    return self;
}

@end
