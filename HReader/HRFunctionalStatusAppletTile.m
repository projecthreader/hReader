//
//  HRFunctionalStatusAppletTile.m
//  HReader
//
//  Created by Marshall Huss on 4/13/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRFunctionalStatusAppletTile.h"

#import "NSDate+FormattedDate.h"

@implementation HRFunctionalStatusAppletTile

@synthesize dateLabel       = __dateLabel;
@synthesize problemLabel    = __problemLabel;
@synthesize typeLabel       = __typeLabel;
@synthesize statusLabel     = __statusLabel;

- (void)tileDidLoad {
    [super tileDidLoad];
    NSDictionary *functionalStatus = [self.patient.syntheticInfo objectForKey:@"functional_status"];

    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[functionalStatus objectForKey:@"date"] doubleValue]];
    self.dateLabel.text = [date mediumStyleDate];
    self.typeLabel.text = [functionalStatus objectForKey:@"type"];
    self.problemLabel.text = [functionalStatus objectForKey:@"problem"];
    self.statusLabel.text = [functionalStatus objectForKey:@"status"];
}

- (void)didReceiveTap:(UIViewController *)sender inRect:(CGRect)rect {
    
}

@end
