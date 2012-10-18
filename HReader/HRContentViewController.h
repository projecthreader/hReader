//
//  HRContentViewController.h
//  HReader
//
//  Created by Caleb Davenport on 10/11/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HRMPatient;

@interface HRContentViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UILabel *patientNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *patientImageView;

/*
 
 Trigger a view reload with the current patient.
 
 */
- (void)reloadData;

/*
 
 Reload view state with the given patient.
 
 */
- (void)reloadWithPatient:(HRMPatient *)patient;

@end
