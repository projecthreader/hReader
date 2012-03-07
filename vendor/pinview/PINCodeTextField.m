//
//  PINCodeTextField.m
//  HReader
//
//  Created by Marshall Huss on 3/7/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "PINCodeTextField.h"

@implementation PINCodeTextField

@synthesize key = __key;

- (void)dealloc {
    self.key = nil;
    [super dealloc];
}

@end
