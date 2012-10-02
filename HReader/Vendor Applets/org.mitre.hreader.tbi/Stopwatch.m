//
//  Stopwatch.m
//  HReader
//
//  Created by Saltzman, Shep on 10/2/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "Stopwatch.h"

NSCalendar *calendar;
bool running;
NSDate *startDate;

@implementation Stopwatch

- (Stopwatch *) init{
    calendar = [NSCalendar currentCalendar];
    running = NO;
    return [Stopwatch alloc];
}

- (void) start{
    if(running){
        NSLog(@"already running"); //should this be an error?
        return;
    }
    startDate = [NSDate new];
}

- (void) checkpoint{}
- (void) stop{}

- (NSString *) description{
    return @"Stopwatch object";
}

- (void) dealloc {
    [calendar dealloc];
    [startDate dealloc];
    [super dealloc];
}

/*

 
 NSDate *date1 = [[NSDate alloc] init];
 
 NSDate *date2 = [[NSDate alloc] initWithTimeInterval:theTimeInterval sinceDate:date1];
 
 // Get conversion to months, days, hours, minutes
 
 unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
 
 NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:date1  toDate:date2  options:0];
 
 
 NSLog(@"Conversion: %dmin %dhours %ddays %dmoths",[conversionInfo minute], [conversionInfo hour], [conversionInfo day], [conversionInfo month]);
 
 
 [date1 release];
 
 
 [date2 release];
 */
@end
