//
//  HRAboutTableViewController.h
//  HReader
//
//  Created by Marshall Huss on 12/12/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PINCodeViewController.h"
#import "PINSecurityQuestionsViewController.h"

@interface HRAboutTableViewController : UITableViewController
<
PINCodeViewControllerDelegate,
PINSecurityQuestionsViewControllerDelegate
>

@property (retain, nonatomic) IBOutlet UILabel *versionLabel;

- (IBAction)done;

@end
