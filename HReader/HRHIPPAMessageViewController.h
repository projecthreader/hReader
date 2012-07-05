//
//  HRHIPPAMessageViewController.h
//  HReader
//
//  Created by Caleb Davenport on 7/5/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRHIPPAMessageViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *buttons;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;

- (IBAction)acceptButtonPressed:(id)sender;
- (IBAction)doNotWant:(id)sender;

+ (BOOL)hasAcceptedHIPPAMessage;

@end
