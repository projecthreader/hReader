//
//  HRConfig.h
//  HReader
//
//  Created by Marshall Huss on 11/15/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "DDXML.h"

//static HRPatient *selectedPatient = nil;

@interface HRConfig ()
//+ (void)parseEncounters;
@end


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

+ (NSString *)feedbackEmailAddress {
    return @"hReader Feedback <hreader@googlegroups.com>";
}

#pragma mark - Colors

+ (UIColor *)textureColor {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"handmadepaper"]];
}

// RGB (217 16 55)
+ (UIColor *)redColor {
//    return [UIColor colorWithRed:148/255.0 green:17/255.0 blue:0/255.0 alpha:1.0];
    return [UIColor colorWithRed:217/255.0 green:16/255.0 blue:55/255.0 alpha:1.0];
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

@end
