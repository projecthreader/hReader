//
//  HRRootViewController_private.h
//  HReader
//
//  Created by Caleb Davenport on 6/4/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRPeoplePickerViewController.h"

@interface HRPeoplePickerViewController ()

/*
 
 
 
 */
+ (HRMPatient *)selectedPatientInContext:(NSManagedObjectContext *)context;

/*
 
 
 
 */
+ (void)setSelectedPatient:(HRMPatient *)patient;

@end
