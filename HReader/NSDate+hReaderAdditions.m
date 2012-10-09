//
//  NSDate+hReaderAdditions.m
//  HReader
//
//  Created by Caleb Davenport on 10/9/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "NSDate+hReaderAdditions.h"

@implementation NSDate (hReaderAdditions)

- (NSString *)hr_mediumStyleDate {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        formatter = [[NSDateFormatter alloc] init];
        //        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setDateFormat:@"d MMM y"];
    });
    return [formatter stringFromDate:self];
}

- (NSString *)hr_shortStyleDate {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        formatter = [[NSDateFormatter alloc] init];
        //        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"dMMMy"];
    });
    return [formatter stringFromDate:self];
    
}

- (NSString *)hr_ageString {
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
