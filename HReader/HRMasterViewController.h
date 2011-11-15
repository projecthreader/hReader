//
//  HRMasterViewController.h
//  HReader
//
//  Created by Marshall Huss on 11/14/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HRDetailViewController;

@interface HRMasterViewController : UITableViewController

@property (strong, nonatomic) HRDetailViewController *detailViewController;
@property (strong, nonatomic) NSArray *patientsArray;

@end
