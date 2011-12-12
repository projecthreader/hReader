//
//  HRAboutTableViewController.h
//  HReader
//
//  Created by Marshall Huss on 12/12/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRAboutTableViewController : UITableViewController

@property (retain, nonatomic) IBOutlet UILabel *versionLabel;

- (IBAction)done:(id)sender;

@end
