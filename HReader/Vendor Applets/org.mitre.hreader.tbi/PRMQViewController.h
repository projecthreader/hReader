//
//  PRMQViewController.h
//  HReader
//
//  Created by Saltzman, Shep on 8/21/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestViewController.h"

@interface PRMQViewController : TestViewController
    
@property (retain, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (retain, nonatomic) IBOutlet UILabel *questionText;

-(IBAction) segmentedControlIndexChanged;
-(IBAction) detectedClick;

@end
