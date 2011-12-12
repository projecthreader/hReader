//
//  HRAddress.h
//  HReader
//
//  Created by Marshall Huss on 12/12/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRAddress : NSObject

@property (copy, nonatomic) NSString *street1;
@property (copy, nonatomic) NSString *street2;
@property (copy, nonatomic) NSString *city;
@property (copy, nonatomic) NSString *state;
@property (copy, nonatomic) NSString *zip;

- (id)initWithSteet1:(NSString *)street1 street2:(NSString *)street2 city:(NSString *)city state:(NSString *)state zip:(NSString *)zip;

@end
