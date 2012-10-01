//
//  NSSet+hReaderAdditions.h
//  HReader
//
//  Created by Caleb Davenport on 9/18/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSet (hReaderAdditions)

- (NSArray *)hr_collect:(id (^) (id object))block;

@end
