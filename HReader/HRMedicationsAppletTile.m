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

@implementation HRMedicationsAppletTile

@synthesize medications         = __medications;
@synthesize medicationLabels    = __medicationLabels;
@synthesize dosageLabels        = __dosageLabels;

#pragma mark - class methods


+ (HRAppletTile *)tile {
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
    return [[nib instantiateWithOwner:self options:nil] lastObject];
}

#pragma mark object methods

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setMedications:(NSArray *)medications {
    __medications = medications;
    
    NSUInteger medicationsCount = [medications count];
    [[self.medicationLabels arraySortedByKey:@"tag"] enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        if (idx < medicationsCount) {
            HRMEntry *entry = [medications objectAtIndex:idx];
            label.text = entry.desc;
        }
        else {
            label.text = nil;
        }
    }];
    [[self.dosageLabels arraySortedByKey:@"tag"] enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        if (idx < medicationsCount) {
            HRMEntry *entry = [medications objectAtIndex:idx];
            NSDictionary *dose = entry.dose;
            if ([dose count] > 0) {
                label.text = [dose description];   
            }
            else {
                label.text = @"";
            }
        }
        else {
            label.text = nil;
        }
    }];
}

#pragma mark - gestures

- (void)didReceiveTap:(UIViewController *)sender inRect:(CGRect)rect {
}

@end
