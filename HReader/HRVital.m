//
//  HRVital.m
//  HReader
//
//  Created by Marshall Huss on 2/6/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRVital.h"

#import "NSDate+FormattedDate.h"

@interface HRVital ()
@property (nonatomic, copy, readwrite) NSArray *entries;
@end

@implementation HRVital

@synthesize entries = __entries;

- (void)dealloc {
    self.entries = nil;
    [super dealloc];
}

- (id)initWithEntries:(NSArray *)entries {
    self = [super init];
    if (self) {
        self.entries = entries;
    }
    return self;
}

- (NSArray *)dataPoints {
    NSMutableArray *points = [NSMutableArray arrayWithCapacity:[self.entries count]];
    [self.entries enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(HRMEntry *entry, NSUInteger index, BOOL *stop) {
        double value = [self valueForEntry:entry];
        BOOL isNormal = [self isValueNormal:value];
        UIColor *color = isNormal ? [UIColor blackColor] : [HRConfig redColor];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [self valueStringForValue:value], @"detail",
                                    [entry.date mediumStyleDate], @"title",
                                    color, @"detail_color",
                                    nil];
        [points addObject:dictionary];
    }];
    return [points copy];
}

- (BOOL)isNormal {
    return [self isValueNormal:self.value];
}

- (NSString *)title {
    return [[self.entries lastObject] desc];
}

- (NSDate *)date {
    return [[self.entries lastObject] date];
}

- (NSString *)leftTitle {
    return @"RESULT:";
}

- (NSString *)leftValue {
    return [self valueStringForValue:self.value];
}

- (NSString *)leftUnit {
    return nil;
}

- (NSString *)rightTitle {
    return @"NORMAL:";
}

- (NSString *)rightValue {
    return nil;
}

- (double)normalLow {
    return 0.0;
}

- (double)normalHigh {
    return 0.0;
}

- (double)valueForEntry:(HRMEntry *)entry {
    return [[entry.value objectForKey:@"scalar"] doubleValue];
}

- (double)value {
    return [self valueForEntry:[self.entries lastObject]];
}

- (NSString *)valueStringForValue:(double)value {
    return [NSString stringWithFormat:@"%0.1f", value];
}

- (BOOL)isValueNormal:(double)value {
    double normalLow = [self normalLow];
    double normalHigh = [self normalHigh];
    if (normalLow == normalHigh) {
        return YES;
    }
    else {
        return !(value < normalLow || value > normalHigh);    
    }
}

@end
