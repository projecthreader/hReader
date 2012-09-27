//
//  tbiTest.h
//  HReader
//
//  Created by Kiley, Thomas L. on 6/4/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PRMQViewController.h"
#import "tbiTestMemoryViewController.h"
#import "ResultViewController.h"

#import <QuartzCore/QuartzCore.h> //for debugging only

@interface tbiTest : UIViewController

- (IBAction) nextClicked: (id)sender;
- (IBAction) prevClicked: (id)sender;


@property (retain, nonatomic) IBOutlet UIView *displayArea;
@property (retain, nonatomic) IBOutlet UILabel *testLabel;
@property (retain, nonatomic) IBOutlet UIButton *nextButton;
@property (retain, nonatomic) IBOutlet UIButton *prevButton;
@property (retain, nonatomic) IBOutlet UIProgressView *progressBar;

@property (retain, nonatomic) IBOutlet UILabel *finalScoreLabel;
@property (retain, nonatomic) IBOutlet UILabel *PRMQScoreLabel;

@end
