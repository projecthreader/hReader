//
//  HRMessagesViewController.h
//  HReader
//
//  Created by Marshall Huss on 12/2/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HRPatientSwipeViewController;

@interface HRMessagesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (copy, nonatomic) NSArray *messagesArray;
@property (retain, nonatomic) NSDateFormatter *dateFormatter;

@property (retain, nonatomic) IBOutlet UIView *patientView;
@property (strong, nonatomic) IBOutlet UIView *patientImageShadowView;
@property (strong, nonatomic) IBOutlet UIImageView *patientImageView;

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIView *messageContentView;
@property (retain, nonatomic) IBOutlet UILabel *subjectLabel;
@property (retain, nonatomic) IBOutlet UITextView *bodyLabel;




@end
