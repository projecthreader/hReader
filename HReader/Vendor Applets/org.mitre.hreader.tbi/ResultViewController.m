//
//  ResultViewController.m
//  HReader
//
//  Created by Saltzman, Shep on 9/25/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "ResultViewController.h"

@interface ResultViewController ()

@end

@implementation ResultViewController

- (void) setTestResult:(int)testScore outOf:(int)testMax andPRMQResult:(int)prmqResult{
    NSLog(@"setResults called with values: %i, %i, %i,", testScore, testMax, prmqResult);
    [[self testResultLabel] setText:[NSString stringWithFormat:@"Test Score: %i/%i", testScore, testMax]];
    [[self PRMQResultLabel] setText:[NSString stringWithFormat:@"PRMQ Score: %i", prmqResult]];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    //NSLog(@"checkpoint 1");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    //NSLog(@"checkpoint 4");
    NSLog(@"test: %@", [self parentViewController]);
}

- (void)viewWillAppear:(BOOL)animated {
    //NSLog(@"checkpoint 3");
}

- (void)viewDidLoad
{
    //NSLog(@"checkpoint 2");
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
