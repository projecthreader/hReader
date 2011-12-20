//
//  HRConfig.h
//  HReader
//
//  Created by Marshall Huss on 11/15/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "HRPatient.h"
#import "HRAddress.h"

NSString * const HRPatientDidChangeNotification = @"HRPatientDidChangeNotification";
NSString * const HRPatientKey = @"HRPatientKey";

@implementation HRConfig

#pragma mark - App Info

+ (NSString *)appVersion { 
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)bundleVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (NSString *)formattedVersion {
    return [NSString stringWithFormat:@"%@ (%@)", [self appVersion], [self bundleVersion]];
}

#pragma mark - API Keys

+ (NSString *)testFlightTeamToken {
    return @"e8ef4e7b3c88827400af56886c6fe280_MjYyNTYyMDExLTEwLTE5IDE2OjU3OjQ3LjMyNDk4OQ";
}

#pragma mark - Colors

+ (UIColor *)textureColor {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"handmadepaper"]];
}

+ (UIColor *)redColor {
    return [UIColor colorWithRed:148/255.0 green:17/255.0 blue:0/255.0 alpha:1.0];
}

+ (UIColor *)greenColor {
    return [UIColor colorWithRed:79/255.0 green:142/255.0 blue:0/255.0 alpha:1.0];
}

+ (UIColor *)lightRedColor {
    return [UIColor colorWithRed:216/255.0 green:83/255.0 blue:111/255.0 alpha:1.0];
}


+ (UIColor *)redGradientTopColor {
    return [UIColor colorWithRed:230/255.0 green:107/255.0 blue:124/255.0 alpha:1.0];
}

+ (UIColor *)redGradientBottomColor {
    return [UIColor colorWithRed:221/255.0 green:59/255.0 blue:81/255.0 alpha:1.0];
}

#pragma mark - Objects

+ (NSArray *)patients {
    
    static NSArray *array = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        HRAddress *address = [[HRAddress alloc] initWithSteet1:@"2275 Rolling Run Dr." street2:nil city:@"Woodlawn" state:@"MD" zip:@"21244"];
        
        HRPatient *johnny = [[[HRPatient alloc] initWithName:@"Johhny Smith" image:[UIImage imageNamed:@"Johnny_Smith"]] autorelease];
        johnny.address = address;
        johnny.gender = HRPatientGenderMale;
        johnny.birthday = [self dateForString:@"20061122"];
        johnny.placeOfBirth = @"Boston, MA USA";
        johnny.race = @"White";
        johnny.ethnicity = @"Germanic";
        johnny.phoneNumber = @"410.555.0350 (home)";

        
        HRPatient *henry = [[[HRPatient alloc] initWithName:@"Henry Smith" image:[UIImage imageNamed:@"Henry_Smith"]] autorelease];
        henry.address = [[[HRAddress alloc] initWithSteet1:@"323 Summer Hill Ln." street2:nil city:@"Baltimore" state:@"MD" zip:@"21215"] autorelease];
        henry.gender = HRPatientGenderMale;
        henry.birthday = [self dateForString:@"19421012"];
        henry.placeOfBirth = @"Austin, TX USA";
        henry.race = @"White";
        henry.ethnicity = @"Germanic";
        henry.phoneNumber = @"425.555.5492 (cell)";
        
        HRPatient *molly = [[[HRPatient alloc] initWithName:@"Molly Smith" image:[UIImage imageNamed:@"Molly_Smith"]] autorelease];
        molly.address = address;
        molly.gender = HRPatientGenderFemale;
        molly.birthday = [self dateForString:@"19940312"];
        molly.placeOfBirth = @"Manchester, NH USA";
        molly.race = @"White";
        molly.ethnicity = @"Germanic";
        molly.phoneNumber = @"410.555.0350 (home)";
        
        HRPatient *sarah = [[[HRPatient alloc] initWithName:@"Sarah Smith" image:[UIImage imageNamed:@"Sarah_Smith"]] autorelease];
        sarah.address = address;
        sarah.gender = HRPatientGenderFemale;
        sarah.birthday = [self dateForString:@"19741111"];
        sarah.placeOfBirth = @"Boston, MA USA";
        sarah.race = @"White";
        sarah.ethnicity = @"Germanic";
        sarah.phoneNumber = @"410.555.0350 (home)";
        
        HRPatient *tom = [[[HRPatient alloc] initWithName:@"Tom Smith" image:[UIImage imageNamed:@"Tom_Smith"]] autorelease];
        tom.address = address;
        tom.gender = HRPatientGenderMale;
        tom.birthday = [self dateForString:@"19721012"];
        tom.placeOfBirth = @"Milford, MA USA";
        tom.race = @"White";
        tom.ethnicity = @"Germanic";
        tom.phoneNumber = @"410.555.0350 (home)";
        
        [address release];
        
        array = [[NSArray alloc] initWithObjects:johnny, henry, molly, sarah, tom, nil];
    });
    
    
    return array;
}

#pragma mark - Helper methods

+ (NSDate *)dateForString:(NSString *)str {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd";
    NSDate *date = [formatter dateFromString:str];
    [formatter release];
    
    return date;
}

+ (void)setShadowForView:(UIView *)shadowView borderForView:(UIView *)borderView {
    CALayer *borderLayer = borderView.layer;
    CALayer *shadowLayer = shadowView.layer;
    
    // Rounded corners
    borderLayer.masksToBounds = YES;
    borderLayer.cornerRadius = 5.0f;
    
    // Shadow
    shadowView.backgroundColor = [UIColor clearColor];
    shadowLayer.shadowColor = [[UIColor blackColor] CGColor];
    shadowLayer.shadowOpacity = 0.5f;
    shadowLayer.shadowOffset = CGSizeMake(3.0f, 2.0f);
    shadowLayer.shadowRadius = 5.0f;
    
    // Border
    borderLayer.borderColor = [[UIColor blackColor] CGColor];
    borderLayer.borderWidth = 2.0f;
    
    
    
    // Page Curl
    //    CGSize size = imageView.bounds.size;
    //    CGFloat curlFactor = 15.0f;
    //    CGFloat shadowDepth = 5.0f;
    //    UIBezierPath *path = [UIBezierPath bezierPath];
    //    [path moveToPoint:CGPointMake(0.0f, 0.0f)];
    //    [path addLineToPoint:CGPointMake(size.width, 0.0f)];
    //    [path addLineToPoint:CGPointMake(size.width, size.height + shadowDepth)];
    //    
    //    [path addCurveToPoint:CGPointMake(0.0f, size.height + shadowDepth)
    //            controlPoint1:CGPointMake(size.width - curlFactor, size.height + shadowDepth - curlFactor)
    //            controlPoint2:CGPointMake(curlFactor, size.height + shadowDepth - curlFactor)];
    //    
    //    imageView.layer.shadowPath = path.CGPath;
}

@end