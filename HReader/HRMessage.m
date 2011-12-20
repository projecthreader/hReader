//
//  HRMessage.m
//  HReader
//
//  Created by Marshall Huss on 12/20/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "HRMessage.h"

@implementation HRMessage

@synthesize subject     = __subject;
@synthesize body        = __body;
@synthesize received    = __received;

+ (HRMessage *)messageWithSubject:(NSString *)subject body:(NSString *)body date:(NSDate *)date {
    HRMessage *message = [[[HRMessage alloc] initWithSubject:subject body:body date:date] autorelease];
    return message;
}

- (id)initWithSubject:(NSString *)subject body:(NSString *)body date:(NSDate *)date {
    self = [super init];
    if (self) {
        self.subject = subject;
        self.body = body;
        self.received = date;
    }
    
    return self;
}

@end
