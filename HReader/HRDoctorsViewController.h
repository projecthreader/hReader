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

@property (retain, nonatomic) IBOutlet UIView *patientView;
@property (retain, nonatomic) IBOutlet UIImageView *doctorImageView;

@end
