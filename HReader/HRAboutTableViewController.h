//
//  HRAboutTableViewController.h
//  HReader
//
//  Created by Marshall Huss on 12/12/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "PINCodeViewController.h"
#import "PINSecurityQuestionsViewController.h"

@interface HRAboutTableViewController : UITableViewController <MFMailComposeViewControllerDelegate>

@property (retain, nonatomic) IBOutlet UILabel *versionLabel;
@property (retain, nonatomic) IBOutlet UILabel *buildDateLabel;

- (IBAction)done;

@end
