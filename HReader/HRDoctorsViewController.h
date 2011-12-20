//
//  HRDoctorsViewController.h
//  HReader
//
//  Created by Marshall Huss on 12/2/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HRPatientSwipeViewController;

@interface HRDoctorsViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIView *doctorDetailView;
@property (retain, nonatomic) IBOutlet UIImageView *doctorImageView;

@property (retain, nonatomic) IBOutlet UIView *patientView;


- (IBAction)showDoctor:(id)sender;
- (IBAction)hideDoctor:(id)sender;


@end