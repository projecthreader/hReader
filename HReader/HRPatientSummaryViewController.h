//
//  HRPatientSummarySplitViewController.h
//  HReader
//
//  Created by Marshall Huss on 11/30/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HRPatientSwipeViewController;

@interface HRPatientSummaryViewController : UIViewController <UIScrollViewDelegate>

@property (retain, nonatomic) IBOutlet UIView *patientHeaderView;
@property (retain, nonatomic) IBOutlet UIScrollView *patientScrollView;
@property (retain, nonatomic) IBOutlet UIView *patientSummaryView;
@property (retain, nonatomic) IBOutlet UILabel *patientName;

@property (retain, nonatomic) IBOutlet UILabel *addressLabel;
@property (retain, nonatomic) IBOutlet UILabel *sexLabel;

@end
