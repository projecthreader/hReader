//
//  HRPatientSummarySplitViewController.h
//  HReader
//
//  Created by Marshall Huss on 11/30/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPatientSummaryViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIView *patientHeaderView;
@property (retain, nonatomic) IBOutlet UIView *patientImageShadowView;
@property (retain, nonatomic) IBOutlet UIImageView *patientImageView;
@property (retain, nonatomic) IBOutlet UIScrollView *patientScrollView;
@property (retain, nonatomic) IBOutlet UIView *patientSummaryView;

@end
