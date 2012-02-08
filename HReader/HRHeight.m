//
//  HRHeight.m
//  HReader
//
//  Created by Marshall Huss on 2/8/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRHeight.h"

@implementation HRHeight

- (id)init {
    self = [super init];
    if (self) {
        self.title = @"Height";
    }
    
    return self;
}

- (BOOL)isNormal {
    return YES;
}

- (NSString *)resultString {
    return @"75";
}

- (NSString *)labelString {
    return @"TH";
}

- (NSString *)normalString {
    return @"3'2\"";
}


@end
