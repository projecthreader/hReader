//
//  HRDoctorsViewController.h
//  HReader
//
//  Created by Marshall Huss on 12/2/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRGridTableView.h"

@class HRPatientImageView;

@interface HRDoctorsViewController : UIViewController <HRGridTableViewDelegate>

@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet HRGridTableView *gridTableView;
@property (nonatomic, strong) IBOutlet UIImageView *patientImageView;

//- (IBAction)patientImageViewSwipe:(HRPatientImageView *)sender;

@end
