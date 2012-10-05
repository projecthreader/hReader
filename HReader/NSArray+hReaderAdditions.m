//
//  NSArray+hReaderAdditions.m
//  HReader
//
//  Created by Caleb Davenport on 9/18/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "NSArray+hReaderAdditions.h"

@implementation NSArray (hReaderAdditions)

- (NSArray *)hr_collect:(id (^) (id object, NSUInteger idx))block {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = block(obj, idx);
        if (value) { [array addObject:value]; }
        else { [array addObject:[NSNull null]]; }
    }];
    return array;
}

- (NSArray *)hr_sortedArrayUsingKey:(NSString *)key ascending:(BOOL)ascending {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending];
    return [self sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
}

- (NSArray *)hr_flatten {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSArray class]]) {
            [array addObjectsFromArray:[obj hr_flatten]];
        }
        else { [array addObject:obj]; }
    }];
    return array;
}

@end
