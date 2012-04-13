//
//  HRAppletConfigurationViewController.h
//  HReader
//
//  Created by Caleb Davenport on 4/13/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const HRAppletConfigurationDidChangeNotification;

@class HRMPatient;

@interface HRAppletConfigurationViewController : UITableViewController

@property (nonatomic, retain) HRMPatient *patient;

@end
