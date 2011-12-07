//
//  HRPatient.h
//  HReader
//
//  Created by Marshall Huss on 12/7/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRPatient : NSObject

@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) UIImage *image;

- (id)initWithName:(NSString *)aName image:(UIImage *)aImage;

@end
