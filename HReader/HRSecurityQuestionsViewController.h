//
//  PINCodeSecurityQuestionsViewController.h
//  HReader
//
//  Created by Marshall Huss on 3/7/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HRSecurityQuestionsViewController;

@protocol HRSecurityQuestionsViewControllerDelegate <NSObject>

@optional

/*
 
 Retuen the questions to display while the contorller is in create or edit
 mode.
 
 */
- (NSArray *)securityQuestions;

@required

/*
 
 The number of security questions that the user has to input. This controls the
 number of table sections that are displayed.
 
 */
- (NSUInteger)numberOfSecurityQuestions;

@end

typedef enum {
    
    // create a new set of security questions and answers
    HRSecurityQuestionsViewControllerModeCreate = 1,
    
    // edit existing questions and answers
    HRSecurityQuestionsViewControllerModeEdit,
    
    // provide answers to questions to be verified
    HRSecurityQuestionsViewControllerModeVerify
    
} HRSecurityQuestionsViewControllerMode;

@interface HRSecurityQuestionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

/*
 
 See `PINSecurityQuestionsViewControllerMode`.
 
 */
@property (nonatomic, assign) HRSecurityQuestionsViewControllerMode mode;

/*
 
 Delegation methods. The delegate must implement the 
 `PINSecurityQuestionsViewControllerDelegate` protocol. The action provided can
 be any method that takes three parameters. The first of these parameters is an
 instance of `PINSecurityQuestionsViewController`, the second is an array of
 questions, and the third is an array of answers. The return
 value of this method can be `void` as it is ignored.
 
 */
@property (nonatomic, assign) id<HRSecurityQuestionsViewControllerDelegate> delegate;
@property (nonatomic, assign) SEL action;

// internal
@property (nonatomic, retain) IBOutlet UITableView *tableView;
- (IBAction)valueChanged:(id)sender;

@end
