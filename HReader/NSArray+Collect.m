//
//  NSArray+Collect.m
//  HReader
//
//  Created by Marshall Huss on 2/29/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "NSArray+Collect.h"

@implementation NSArray (Collect)


- (NSArray *)sortedArrayUsingKey:(NSString *)key ascending:(BOOL)ascending {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending];
    return [self sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];    
}

@end
