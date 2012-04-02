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

- (NSString *)ageString {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *monthComponents = [calendar components:NSMonthCalendarUnit fromDate:self toDate:[NSDate date] options:0];
    NSInteger months = [monthComponents month];
    if (months < 6) {
        NSDateComponents *weekComponents = [calendar components:NSWeekCalendarUnit fromDate:self toDate:[NSDate date] options:0];
        return [NSString stringWithFormat:@"%ld weeks", (long)[weekComponents week]];
    }
    else if (months < 24) {
        return [NSString stringWithFormat:@"%ld months", (long)months];
    }
    else {
        NSDateComponents *yearComponents = [calendar components:NSYearCalendarUnit fromDate:self toDate:[NSDate date] options:0];
        return [NSString stringWithFormat:@"%ld years", (long)[yearComponents year]];
    }
}

@end
