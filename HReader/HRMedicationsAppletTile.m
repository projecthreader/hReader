//
//  HRMedicationsAppletTile.m
//  HReader
//
//  Created by Marshall Huss on 4/11/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRMedicationsAppletTile.h"
#import "HRMedicationsMasterViewController.h"

#import "HRMEntry.h"
#import "HRMPatient.h"

#import "NSString+SentenceCapitalization.h"

@implementation HRMedicationsAppletTile

- (void)tileDidLoad {
    [super tileDidLoad];
    HRMPatient *patient = [self.userInfo objectForKey:@"__private_patient__"];
    NSArray *medications = patient.medications;
    NSArray *nameLabels = [self.medicationLabels hr_sortedArrayUsingKey:@"tag" ascending:YES];
    NSArray *dosageLabels = [self.dosageLabels hr_sortedArrayUsingKey:@"tag" ascending:YES];
    NSUInteger medicationsCount = [medications count];
    NSUInteger labelCount = [nameLabels count];
    BOOL showCountLabel = (medicationsCount > labelCount);
    NSAssert(labelCount == [dosageLabels count], @"There must be an equal number of name and date labels");
    [nameLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
        
        // this is the last label and we should show count
        if (index == labelCount - 1 && showCountLabel) {
            label.text = [NSString stringWithFormat:@"%lu more…", (unsigned long)(medicationsCount - labelCount + 1)];
        }
        
        // normal medication label
        else if (index < medicationsCount) {
            HRMEntry *medication = [medications objectAtIndex:index];
            [label setAttributedText:[medication getDescAttributeString]];
            //label.text = medication.desc;
        }
        
        // no medications
        else if (index == 0) { label.text = @"None"; }
        
        // clear the label
        else { label.text = nil; }
        
    }];
    [dosageLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
        // this is the last label and we should show count
        if (index == labelCount - 1 && showCountLabel) {
            label.text = [NSString stringWithFormat:@"%lu more…", (unsigned long)(medicationsCount - labelCount + 1)];
        }
        
        // normal medication label
        else if (index < medicationsCount) {
            HRMEntry *medication = [medications objectAtIndex:index];
            if(medication.patientComments!=nil){
                label.text=[medication.patientComments objectForKey:DOSE_KEY];
            }else{
                label.text=@"";
            }
        }
        
        // no medications
        else if (index == 0) { label.text = @"None"; }
        
        // clear the label
        else { label.text = nil; }
    }];
}

-(void)didReceiveTap:(UIViewController *)sender inRect:(CGRect)rect
{
 
    UIStoryboard *medicationsStoryboard = [UIStoryboard storyboardWithName:@"HRMedications_iPad" bundle:nil];
    HRMedicationsMasterViewController *controller = [medicationsStoryboard instantiateInitialViewController];
    controller.title = [self.userInfo objectForKey:@"display_name"];
    //controller.tile = self;
    [sender.navigationController pushViewController:controller animated:YES];
    
}



@end
