//
//  HRMedicationsAppletTile.m
//  HReader
//
//  Created by Marshall Huss on 4/11/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRMedicationsAppletTile.h"
#import "HRMEntry.h"
#import "HRMPatient.h"

#import "NSArray+Collect.h"

@implementation HRMedicationsAppletTile

@synthesize medicationLabels    = __medicationLabels;
@synthesize dosageLabels        = __dosageLabels;


#pragma mark object methods

- (void)tileDidLoad {
    [super tileDidLoad];
    
    NSArray *medications = [self.patient medications];
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
