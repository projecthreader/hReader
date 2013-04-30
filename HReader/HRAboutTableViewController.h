//
//  HRAboutTableViewController.h
//  HReader
//
//  Created by Marshall Huss on 12/12/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AppPassword/APPassProtocol.h>

@interface HRAboutTableViewController : UITableViewController
<MFMailComposeViewControllerDelegate, APPassProtocol>

@end
