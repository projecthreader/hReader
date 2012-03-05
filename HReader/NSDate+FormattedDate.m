//
//  NSDate+HReaderAdditions.m
//  HReader
//
//  Created by Caleb Davenport on 2/23/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "NSDate+FormattedDate.h"

@implementation NSDate (FormattedDate)

- (NSString *)mediumStyleDate {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
    });
    return [formatter stringFromDate:self];
}

- (NSString *)shortStyleDate {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
    });
    return [formatter stringFromDate:self];
    
}

@end
