//
//  TestViewController.m
//  HReader
//
//  Created by Saltzman, Shep on 8/17/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

// TEST COMMENT FOR CHECKIN

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    //NSLog(@"TestViewController's viewDidLoad called.");
    //NSLog(@"%@", [[self view] recursiveDescription]);
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //NSLog(@"My view is: %@", [self view]);
    //NSLog(@"%@", [[self view] recursiveDescription]);
    self.view.frame = CGRectMake(0, 0, 976, 1024);
    self.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0]; //transparent
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (int)result //this should be two ints: #right / #total
{
    return 0;
}

@end
