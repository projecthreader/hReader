//
//  NSArray+Collect.h
//  HReader
//
//  Created by Marshall Huss on 2/29/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Collect)


- (NSArray *)sortedArrayUsingKey:(NSString *)key ascending:(BOOL)ascending;

@end
