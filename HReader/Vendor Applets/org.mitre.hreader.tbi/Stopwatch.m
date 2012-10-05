//
//  Stopwatch.m
//  HReader
//
//  Created by Saltzman, Shep on 10/2/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "Stopwatch.h"

bool running;
NSDate *startTime;
NSDate *stopTime;
NSMutableArray *stopTimes;
unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit; 

@implementation Stopwatch

- (Stopwatch *) init{
    NSLog(@"initializing Stopwatch");
    //calendar = [NSCalendar currentCalendar];
    //[calendar retain]; //this is necessary, but there's probably a better way
    running = NO;
    return [Stopwatch alloc];
}

- (void) start{
    NSLog(@"starting Stopwatch");
    if(running){
        NSLog(@"already running"); //should this be an error? or perhaps restart the stopwatch?
        return;
    }
    else{
        startTime = [NSDate new];
        running = YES;
        stopTime = nil;
    }
}

- (void) checkpoint{}

- (void) stop{
    if(running){
        stopTime = [NSDate new];
        running = NO;
    }
    else{
        NSLog(@"wasn't running"); //throw error?
    }
}

- (NSString *) description{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *conversionInfo;
    if (!startTime){
        return @"0 seconds";
    }
    if (stopTime){
        conversionInfo = [calendar components:unitFlags fromDate:startTime toDate:stopTime options:0];
    }
    else{
        conversionInfo = [calendar components:unitFlags fromDate:startTime toDate:[[NSDate alloc] init] options:0];
    }
    if ([conversionInfo hour] > 0){
        return [NSString stringWithFormat:@"%d hours, %d minutes, %d seconds", [conversionInfo hour], [conversionInfo minute], [conversionInfo second]];
    }
    else{
        return [NSString stringWithFormat:@"%d minutes, %d seconds", [conversionInfo minute], [conversionInfo second]];
    }
}

- (void) dealloc {
    [startTime dealloc];
    [stopTime dealloc];
    [super dealloc];
}

@end
