//
//  HRSplitViewController.m
//  HReader
//
//  Created by Marshall Huss on 11/30/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "HRSplitViewController.h"

@implementation HRSplitViewController

@synthesize detailView = __detailView;

- (void)dealloc {
    [__detailView release];
    
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.detailView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
