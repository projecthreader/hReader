//
//  PRMQViewController.m
//  HReader
//
//  Created by Saltzman, Shep on 8/21/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "PRMQViewController.h"

@interface PRMQViewController ()

@end

@implementation PRMQViewController

//Note to self: this is a class variable. It needs to be an instance variable. 
//int selected = 1;

-(IBAction) detectedClick{
    NSLog(@"click detected");
}

-(IBAction) segmentedControlIndexChanged{
    /*
    NSLog(@"I noticed a change! Now index is: %i", self.segmentedControl.selectedSegmentIndex);
    [self.segmentedControl setEnabled:YES forSegmentAtIndex:4];
    NSLog(@"segment 3 enabled?: %d", [self.segmentedControl isEnabledForSegmentAtIndex:3]);
    NSLog(@"segment 4 enabled?: %d", [self.segmentedControl isEnabledForSegmentAtIndex:4]);
    */
    //selected = self.segmentedControl.selectedSegmentIndex + 1;
}

- (int)result {
    //NSLog(@"PRMQ result called, returning: %i", self.segmentedControl.selectedSegmentIndex+1);
    //NSLog(@"But I could also return return %i instead", selected);
    return self.segmentedControl.selectedSegmentIndex + 1;
    //return selected;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    //NSLog(@"initWithNibName called");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    //NSLog(@"viewDidLoad called");
    //[self.segmentedControl setEnabled:YES forSegmentAtIndex:4];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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



@end
