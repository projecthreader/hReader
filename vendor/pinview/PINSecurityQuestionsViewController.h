//
//  PINCodeSecurityQuestionsViewController.h
//  HReader
//
//  Created by Marshall Huss on 3/7/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PINSecurityQuestionsViewController;

@protocol PINSecurityQuestionsViewControllerDelegate <NSObject>

@required

- (NSUInteger)numberOfSecurityQuestions;

- (NSArray *)securityQuestions;

- (void)securityQuestionsController:(PINSecurityQuestionsViewController *)controller
                 didSubmitQuestions:(NSArray *)questions
                            answers:(NSArray *)answers;

- (void)securityQuestionsControllerDidCancel:(PINSecurityQuestionsViewController *)controller;

@end

typedef enum {
    PINSecurityQuestionsViewControllerCreate = 1,
    PINSecurityQuestionsViewControllerEdit,
    PINSecurityQuestionsViewControllerVerify
} PINSecurityQuestionsViewControllerMode;

@interface PINSecurityQuestionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, assign) PINSecurityQuestionsViewControllerMode mode;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, assign) id<PINSecurityQuestionsViewControllerDelegate> delegate;

- (IBAction)valueChanged:(id)sender;

@end
