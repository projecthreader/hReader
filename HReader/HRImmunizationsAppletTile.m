//
//  HRImmunizationsAppletTile.m
//  HReader
//
//  Created by Marshall Huss on 4/11/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRImmunizationsAppletTile.h"
#import "HRMPatient.h"

@implementation HRImmunizationsAppletTile

@synthesize upToDateLabel = __upToDateLabel;

#pragma mark object methods

- (void)tileDidLoad {
    [super tileDidLoad];
    
    // immunizations
    if ([[self.patient.syntheticInfo objectForKey:@"immunizations"] boolValue]) {
        self.upToDateLabel.text = @"Yes";
        self.upToDateLabel.textColor = [HRConfig greenColor];
    }
    else {
        self.upToDateLabel.text = @"No";
        self.upToDateLabel.textColor = [HRConfig redColor];
    }
}

#pragma mark - gestures

- (void)didReceiveTap:(UIViewController *)sender inRect:(CGRect)rect {
}

@end
