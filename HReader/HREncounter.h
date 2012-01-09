//
//  HREncounter.h
//  HReader
//
//  Created by Marshall Huss on 1/9/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HREncounter : NSObject

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *code;
@property (copy, nonatomic) NSDate *date;

- (id)initWithTitle:(NSString *)title code:(NSString *)code date:(NSDate *)date;

@end
