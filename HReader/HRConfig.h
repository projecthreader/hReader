//
//  HRConfig.h
//  HReader
//
//  Created by Marshall Huss on 11/15/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const HRPatientDidChangeNotification;
extern NSString * const HRPatientKey;

@interface HRConfig : NSObject

+ (NSString *)appVersion;
+ (NSString *)bundleVersion;
+ (NSString *)formattedVersion;

+ (NSString *)testFlightTeamToken;

+ (UIColor *)textureColor;
+ (UIColor *)redColor;
+ (UIColor *)greenColor;
+ (UIColor *)lightRedColor;
+ (UIColor *)redGradientTopColor;
+ (UIColor *)redGradientBottomColor;

+ (NSArray *)patients;

+ (BOOL)hasLaunched;
+ (void)setHasLaunched:(BOOL)hasLaunched;
+ (BOOL)passcodeEnabled;
+ (void)setPasscodeEnabled:(BOOL)passcodeEnabled;

+ (NSDate *)dateForString:(NSString *)birthday;
+ (void)setShadowForView:(UIView *)shadowView borderForView:(UIView *)borderView;

@end