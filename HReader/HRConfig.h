//
//  HRConfig.h
//  HReader
//
//  Created by Marshall Huss on 11/15/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HRPatient;

extern NSString * const HRPatientKey;

@interface HRConfig : NSObject

+ (NSString *)appVersion;
+ (NSString *)bundleVersion;
+ (NSString *)formattedVersion;
+ (NSString *)feedbackEmailAddress;

+ (NSString *)testFlightTeamToken;

+ (UIColor *)textureColor;
+ (UIColor *)redColor;
+ (UIColor *)greenColor;
+ (UIColor *)lightRedColor;
+ (UIColor *)redGradientTopColor;
+ (UIColor *)redGradientBottomColor;

+ (BOOL)hasLaunched;
+ (void)setHasLaunched:(BOOL)hasLaunched;
+ (BOOL)passcodeEnabled;
+ (void)setPasscodeEnabled:(BOOL)passcodeEnabled;
+ (BOOL)privacyWarningConfirmed;
+ (void)setPrivacyWarningConfirmed:(BOOL)confirmed;


//+ (NSDate *)dateForString:(NSString *)birthday;

@end

