//
//  HRImmunizationsAppletTile.m
//  HReader
//
//  Created by Marshall Huss on 4/11/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRImmunizationsAppletTile.h"

@implementation HRImmunizationsAppletTile

@synthesize upToDateLabel = __upToDateLabel;

- (void)tileDidLoad {
    [super tileDidLoad];
    if ([[self.patient.syntheticInfo objectForKey:@"immunizations"] boolValue]) {
        self.upToDateLabel.text = @"Yes";
        self.upToDateLabel.textColor = [HRConfig greenColor];
    }
    else {
        self.upToDateLabel.text = @"No";
        self.upToDateLabel.textColor = [HRConfig redColor];
    }
}

@end
