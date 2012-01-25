//
//  HRCondition.h
//  HReader
//
//  Created by Marshall Huss on 1/25/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRCondition : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *description;
@property (copy, nonatomic) NSDate *date;
@property (nonatomic) BOOL chronic;

- (id)initWithName:(NSString *)name description:(NSString  *)description date:(NSDate *)date chronic:(BOOL)chronic;

@end
