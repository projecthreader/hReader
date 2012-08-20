//
//  HRFunctionalStatusAppletTile.m
//  HReader
//
//  Created by Marshall Huss on 4/13/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRFunctionalStatusAppletTile.h"

#import "HRMPatient.h"

#import "NSDate+FormattedDate.h"

@implementation HRFunctionalStatusAppletTile

- (void)tileDidLoad {
    [super tileDidLoad];
    HRMPatient *patient = [self.userInfo objectForKey:@"__private_patient__"];
    NSDictionary *functionalStatus = [patient.syntheticInfo objectForKey:@"functional_status"];
    if (functionalStatus) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[functionalStatus objectForKey:@"date"] doubleValue]];
        self.dateLabel.text = [date mediumStyleDate];
        self.typeLabel.text = [functionalStatus objectForKey:@"type"];
        self.problemLabel.text = [functionalStatus objectForKey:@"problem"];
        self.statusLabel.text = [functionalStatus objectForKey:@"status"];
    }
    else {
        self.dateLabel.text = @"None";
        self.typeLabel.text = nil;
        self.problemLabel.text = nil;
        self.statusLabel.text = nil;
    }
}

@end
