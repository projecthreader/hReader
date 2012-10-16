//
//  HRAppletConfigurationViewController.h
//  HReader
//
//  Created by Caleb Davenport on 4/13/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRAppletConfigurationViewController : UITableViewController

/*
 
 Get a list of all applet definitions present in the system.
 
 */
+ (NSArray *)availableApplets;

/*
 
 Get the applet definition that has the provided identifier.
 
 */
+ (NSDictionary *)appletWithIdentifier:(NSString *)identifier;

@end
