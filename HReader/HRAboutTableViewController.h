//
//  HRAboutTableViewController.h
//  HReader
//
//  Created by Marshall Huss on 12/12/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface HRAboutTableViewController : UITableViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UILabel *versionLabel;
@property (nonatomic, strong) IBOutlet UILabel *buildDateLabel;

- (IBAction)done;

@end
