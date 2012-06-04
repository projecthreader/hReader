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

@interface HRDoctorsViewController : UIViewController <HRGridTableViewDelegate, HRGridTableViewDataSource>

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet HRGridTableView *gridTableView;
@property (nonatomic, weak) IBOutlet UIImageView *patientImageView;

@end
