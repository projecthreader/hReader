//
//  HREncountersAppletTile.m
//  HReader
//
//  Created by Marshall Huss on 4/11/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HREncountersAppletTile.h"
#import "HRMEntry.h"
#import "HRMPatient.h"

#import "NSDate+FormattedDate.h"

@implementation HREncountersAppletTile

@synthesize dateLabel           = __dateLabel;
@synthesize typeLabel           = __typeLabel;
@synthesize descriptionLabel    = __descriptionLabel;

#pragma mark - class methods


#pragma mark object methods

- (void)tileDidLoad {
    [super tileDidLoad];
    
    NSSortDescriptor *encounterSort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSArray *encounters = [self.patient.encounters sortedArrayUsingDescriptors:[NSArray arrayWithObject:encounterSort]];
    HRMEntry *encounter = [encounters lastObject];
    self.dateLabel.text = [encounter.date mediumStyleDate];
    self.descriptionLabel.text = encounter.desc;
    NSDictionary *codes = encounter.codes;
    NSDictionary *codeType = [[codes allKeys] lastObject];
    NSString *codeValues = [[codes objectForKey:codeType] componentsJoinedByString:@", "];
    self.typeLabel.text = [NSString stringWithFormat:@"%@ %@", codeType, codeValues];
    
}

#pragma mark - gestures

- (void)didReceiveTap:(UIViewController *)sender inRect:(CGRect)rect {
}

@end
