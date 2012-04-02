//
//  NSDate+HReaderAdditions.h
//  HReader
//
//  Created by Caleb Davenport on 2/23/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (FormattedDate)

- (NSString *)mediumStyleDate;
- (NSString *)shortStyleDate;
- (NSString *)timeAgoInWords;

@end
