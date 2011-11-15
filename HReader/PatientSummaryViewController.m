//
//  PatientSummaryViewController.m
//  HReader
//
//  Created by Marshall Huss on 11/15/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "PatientSummaryViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation PatientSummaryViewController

@synthesize patientImageView = __patientImageView;
@synthesize patientNameLabel = __patientNameLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [__patientNameLabel release];
    [__patientImageView release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = TEXTURE_COLOR;
    self.patientImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.patientImageView.layer.borderWidth = 3.0;
    
    self.patientImageView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.patientImageView.layer.shadowOffset = CGSizeMake(0, 3);
    self.patientImageView.layer.shadowOpacity = 0.5;
    
    self.patientNameLabel.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    self.patientNameLabel.layer.shadowOpacity = 0.5;
    self.patientNameLabel.layer.shadowOffset = CGSizeMake(0, 3);
    self.patientNameLabel.layer.masksToBounds = NO;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.patientImageView = nil;
    self.patientNameLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

@end
