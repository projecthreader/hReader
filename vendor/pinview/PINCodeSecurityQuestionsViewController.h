//
//  PINCodeSecurityQuestionsViewController.h
//  HReader
//
//  Created by Marshall Huss on 3/7/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PINSecurityQuestionModeCreate = 1,
    PINSecurityQuestionModeEdit,
    PINSecurityQuestionModeVerify
} PINSecurityQuestionMode;

@interface PINCodeSecurityQuestionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (IBAction)valueChanged:(id)sender;

- (void)setMode:(PINSecurityQuestionMode)mode;

@end
