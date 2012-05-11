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
    NSArray *nameLabels = [self.medicationLabels sortedArrayUsingKey:@"tag" ascending:YES];
    NSArray *dosageLabels = [self.dosageLabels sortedArrayUsingKey:@"tag" ascending:YES];
    NSUInteger medicationsCount = [medications count];
    NSUInteger labelCount = [nameLabels count];
    BOOL showCountLabel = (medicationsCount > labelCount);
    NSAssert(labelCount == [dosageLabels count], @"There must be an equal number of name and date labels");
    [nameLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
        
        // this is the last label and we should show count
        if (index == labelCount - 1 && showCountLabel) {
            label.text = [NSString stringWithFormat:@"%lu more…", medicationsCount - labelCount + 1];
        }
        
        // normal condition label
        else if (index < medicationsCount) {
            HRMEntry *condition = [medications objectAtIndex:index];
            label.text = condition.desc;
        }
        
        // no conditions
        else if (index == 0) { label.text = @"None"; }
        
        // clear the label
        else { label.text = nil; }
        
    }];
    [dosageLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
        label.text = nil;
    }];
}

@end
