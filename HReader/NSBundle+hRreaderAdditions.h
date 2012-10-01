//
//  NSBundle+hRreaderAdditions.h
//  HReader
//
//  Created by Caleb Davenport on 9/18/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (hRreaderAdditions)

- (NSString *)hr_shortVersionString;
- (NSString *)hr_version;
- (NSString *)hr_displayVersion;
- (NSString *)hr_buildTime;

@end
