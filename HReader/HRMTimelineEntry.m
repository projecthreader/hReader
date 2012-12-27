//
//  HRMTimelineEntry.m
//  HReader
//
//  Created by Caleb Davenport on 12/13/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRMTimelineEntry.h"

@implementation HRMTimelineEntry

@dynamic createdAt;
@dynamic data;
@dynamic type;
@dynamic patient;

+ (NSString *)modelName {
    return @"TimelineEntry";
}

@end
