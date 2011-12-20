//
//  HRMessage.h
//  HReader
//
//  Created by Marshall Huss on 12/20/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRMessage : NSObject

@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSDate *received;


+ (HRMessage *)messageWithSubject:(NSString *)subject body:(NSString *)body date:(NSDate *)date;
- (id)initWithSubject:(NSString *)subject body:(NSString *)body date:(NSDate *)date;

@end
