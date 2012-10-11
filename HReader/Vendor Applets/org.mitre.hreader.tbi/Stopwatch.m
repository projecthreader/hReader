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
    stopTimes = [NSMutableArray new];
    return [Stopwatch alloc];
}

- (void) start{
    NSLog(@"starting Stopwatch");
    if(running){
        NSLog(@"Stopwatch: start called but watch already running"); //should this be an error? or perhaps restart/checkpoint the stopwatch?
        return;
    }
    else{
        startTime = [NSDate new];
        [stopTimes removeAllObjects];
        [stopTimes addObject: [NSDate new]];
        running = YES;
        stopTime = nil;
    }
}

- (void) checkpoint{
    if(running){
        [stopTimes addObject: [NSDate new]];
    }
    else{
        NSLog(@"Stopwatch: checkpoint called but watch wasn't running");
    }
}

- (void) stop{
    if(running){
        stopTime = [NSDate new];
        [stopTimes addObject: [NSDate new]];
        running = NO;
    }
    else{
        NSLog(@"Stopwatch: stop called but watch wasn't running"); //throw error?
    }
}

- (NSString *) description{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *conversionInfo;
    if ((int)[stopTimes count] == 0){
        return @"0 seconds";
    }
    else if ((int)[stopTimes count] == 1){ //we can assume the stopwatch is running... I think...
        conversionInfo = [calendar components:unitFlags fromDate:[stopTimes objectAtIndex:0] toDate:[NSDate new] options:0];
        return [NSString stringWithFormat:@"%d minutes, %d seconds", [conversionInfo minute], [conversionInfo second]];
    }
    else {
        NSString *returnString = [NSString new];
        returnString = @"\n";
        for(int i=1; i<(int)[stopTimes count]; i++){
            conversionInfo = [calendar components:unitFlags fromDate:[stopTimes objectAtIndex:(i-1)] toDate:[stopTimes objectAtIndex:i] options:0];
            returnString = [returnString stringByAppendingString:[NSString stringWithFormat:@"%d minutes, %d seconds\n", [conversionInfo minute], [conversionInfo second]]];
        }
        if(running){
            conversionInfo = [calendar components:unitFlags fromDate:[stopTimes lastObject] toDate:[NSDate new] options:0];
            returnString = [returnString stringByAppendingString:[NSString stringWithFormat:@"%d minutes, %d seconds\n", [conversionInfo minute], [conversionInfo second]]];
        }
        conversionInfo = [calendar components:unitFlags fromDate:[stopTimes objectAtIndex:0] toDate:[NSDate new] options:0];
        returnString = [returnString stringByAppendingString:[NSString stringWithFormat:@"Total Time: %d minutes, %d seconds\n", [conversionInfo minute], [conversionInfo second]]];
        return returnString;
    }
    /*
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
    */
}

- (void) dealloc {
    [startTime dealloc];
    [stopTime dealloc];
    [stopTimes dealloc];
    [super dealloc];
}

@end
