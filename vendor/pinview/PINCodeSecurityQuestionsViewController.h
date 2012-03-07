//
//  PINCodeSecurityQuestionsViewController.h
//  HReader
//
//  Created by Marshall Huss on 3/7/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PINCodeSecurityQuestionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (IBAction)valueChanged:(id)sender;

@end
