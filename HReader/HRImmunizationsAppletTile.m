//
//  HRImmunizationsAppletTile.m
//  HReader
//
//  Created by Marshall Huss on 4/11/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRImmunizationsAppletTile.h"

#import "HRMEntry.h"
#import "HRMPatient.h"

#import "NSString+SentenceCapitalization.h"
#import "NSDate+FormattedDate.h"

@implementation HRImmunizationsAppletTile

- (void)tileDidLoad {
    [super tileDidLoad];
    HRMPatient *patient = [self.userInfo objectForKey:@"__private_patient__"];
    NSArray *immunizations = patient.immunizations;
    NSArray *immunizationLabels = [self.immunizationLabels hr_sortedArrayUsingKey:@"tag" ascending:YES];
    NSArray *dateLabels = [self.dateLabels hr_sortedArrayUsingKey:@"tag" ascending:YES];
    NSUInteger immunizationsCount = [immunizations count];
    NSUInteger labelCount = [dateLabels count];
    BOOL showCountLabel = (immunizationsCount > labelCount);
    NSAssert(labelCount == [dateLabels count], @"There must be an equal number of name and date labels");
    [immunizationLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
        
        // this is the last label and we should show count
        if (index == labelCount - 1 && showCountLabel) {
            label.text = [NSString stringWithFormat:@"%lu more…", (unsigned long)(immunizationsCount - labelCount + 1)];
        }
        
        // normal condition label
        else if (index < immunizationsCount) {
            HRMEntry *immunization = [immunizations objectAtIndex:index];
            label.text = immunization.desc;
        }
        
        // no conditions
        else if (index == 0) { label.text = @"None"; }
        
        // clear the label
        else { label.text = nil; }
        
    }];
    [dateLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
        if (index == labelCount - 1 && showCountLabel) {
            label.text = nil;
        }
        else if (index < immunizationsCount) {
            HRMEntry *immunization = [immunizations objectAtIndex:index];
            label.text = [immunization.date mediumStyleDate];
        }
        else { label.text = nil; }
    }];
}

@end
