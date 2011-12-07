//
//  HRConfig.h
//  HReader
//
//  Created by Marshall Huss on 11/15/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const HRPatientDidChangeNotification;

@interface HRConfig : NSObject

+ (UIColor *)textureColor;
+ (UIColor *)redColor;
+ (UIColor *)greenColor;
+ (UIColor *)lightRedColor;
+ (UIColor *)redGradientTopColor;
+ (UIColor *)redGradientBottomColor;

+ (NSArray *)patients;

+ (void)setShadowForView:(UIView *)shadowView borderForView:(UIView *)borderView;

@end