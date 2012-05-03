//
//  NSArray+Collect.m
//  HReader
//
//  Created by Marshall Huss on 2/29/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "NSArray+Collect.h"

@implementation NSArray (Collect)

- (NSArray *)collect:(id (^) (id object, NSUInteger idx))block {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id retVal = block(obj, idx);
        if (retVal) {
            [array addObject:retVal];
        }
        else {
            [array addObject:[NSNull null]];
        }
    }];
    return array;
}

- (NSArray *)sortedArrayUsingKey:(NSString *)key ascending:(BOOL)ascending {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending];
    return [self sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];    
}

@end