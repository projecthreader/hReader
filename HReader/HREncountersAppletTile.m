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
#import "NSString+SentenceCapitalization.h"

@implementation HREncountersAppletTile

- (void)tileDidLoad {
    [super tileDidLoad];
    HRMPatient *patient = [self.userInfo objectForKey:@"__private_patient__"];
    HRMEntry *encounter = [patient.encounters lastObject];
    if (encounter) {
        self.dateLabel.text = [encounter.date mediumStyleDate];
        self.descriptionLabel.text = [encounter.desc sentenceCapitalizedString];
        NSDictionary *codes = encounter.codes;
        NSDictionary *codeType = [[codes allKeys] lastObject];
        NSString *codeValues = [[codes objectForKey:codeType] componentsJoinedByString:@", "];
        self.typeLabel.text = [NSString stringWithFormat:@"%@ %@", codeType, codeValues];
    }
    else {
        self.dateLabel.text = @"None";
        self.descriptionLabel.text = nil;
        self.typeLabel.text = nil;
    }
}

@end
