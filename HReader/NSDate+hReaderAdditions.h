//
//  NSDate+hReaderAdditions.h
//  HReader
//
//  Created by Caleb Davenport on 10/9/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (hReaderAdditions)

- (NSString *)hr_mediumStyleDate;
- (NSString *)hr_shortStyleDate;
- (NSString *)hr_ageString;

@end
