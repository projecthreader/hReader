//
//  NSSet+hReaderAdditions.m
//  HReader
//
//  Created by Caleb Davenport on 9/18/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "NSSet+hReaderAdditions.h"

@implementation NSSet (hReaderAdditions)

- (NSArray *)hr_collect:(id (^) (id object))block {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        id value = block(obj);
        if (value) { [array addObject:value]; }
        else { [array addObject:[NSNull null]]; }
    }];
    return array;
}

@end
