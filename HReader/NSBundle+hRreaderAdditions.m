//
//  NSBundle+hRreaderAdditions.m
//  HReader
//
//  Created by Caleb Davenport on 9/18/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "NSBundle+hRreaderAdditions.h"

@implementation NSBundle (hRreaderAdditions)

- (NSString *)hr_shortVersionString {
    return [[self infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (NSString *)hr_version {
    return [[self infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (NSString *)hr_displayVersion {
    return [NSString stringWithFormat:@"%@ (%@)", [self hr_shortVersionString], [self hr_version]];
}

- (NSString *)hr_buildTime {
    return [[self infoDictionary] objectForKey:@"CMDBundleBuildTime"];
}

@end
