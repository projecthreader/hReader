//
//  HRMedicationsAppletTile.m
//  HReader
//
//  Created by Marshall Huss on 4/11/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRMedicationsAppletTile.h"
#import "HRMEntry.h"

#import "NSArray+Collect.h"
#import "NSString+SentenceCapitalization.h"

@implementation HRMedicationsAppletTile

@synthesize medicationLabels = __medicationLabels;
@synthesize dosageLabels = __dosageLabels;

- (void)tileDidLoad {
    [super tileDidLoad];
    NSArray *medications = [[self patient] medications];
    NSUInteger medicationsCount = [medications count];
    [[self.medicationLabels sortedArrayUsingKey:@"tag" ascending:YES] enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
        if (index < medicationsCount) {
            HRMEntry *entry = [medications objectAtIndex:index];
            label.text = [entry.desc sentenceCapitalizedString];
        }
        else if (index == 0) { label.text = @"None"; }
        else { label.text = nil; }
    }];
    [[self.dosageLabels sortedArrayUsingKey:@"tag" ascending:YES] enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
//        if (idx < medicationsCount) {
//            HRMEntry *entry = [medications objectAtIndex:idx];
//            NSDictionary *dose = entry.dose;
//            if ([dose count] > 0) {
//                label.text = [dose description];   
//            }
//            else {
//                label.text = @"";
//            }
//        }
//        else {
            label.text = nil;
//        }
    }];
}

@end
