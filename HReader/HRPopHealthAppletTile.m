//
//  HRPopHealthAppletTile.m
//  HReader
//
//  Created by Adam Goldstein on 11/26/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRPopHealthAppletTile.h"
#import "HRMPatient.h"

@implementation HRPopHealthAppletTile

- (void)tileDidLoad {
    [super tileDidLoad];
    HRMPatient *patient = [self.userInfo objectForKey:@"__private_patient__"];
}

@end
