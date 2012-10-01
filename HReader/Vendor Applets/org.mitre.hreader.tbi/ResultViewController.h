//
//  ResultViewController.h
//  HReader
//
//  Created by Saltzman, Shep on 9/25/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestViewController.h"

@interface ResultViewController : TestViewController 

@property (retain, nonatomic) IBOutlet UILabel *testResultLabel;
@property (retain, nonatomic) IBOutlet UILabel *PRMQResultLabel;

- (void) setTestResult:(int)testScore outOf:(int)testMax andPRMQResult:(int)prmqResult;

@end
