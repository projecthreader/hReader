//
//  TBITrackerAppletTile.m
//  HReader
//
//  Created by Lindsay Kaye on 5/14/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "TBITrackerAppletTile.h"
#import "TBITrackerDashboard.h"

@implementation TBITrackerAppletTile



#pragma mark - View lifecycle

- (void)tileDidLoad
{
    [super tileDidLoad];
    // Do any additional setup after loading the view from its nib.

}

-(void)didReceiveTap:(UIViewController *)sender inRect:(CGRect)rect
{
    UIViewController *controller = [[TBITrackerDashboard alloc] init];
    controller.title = [self.userInfo objectForKey:@"display_name"];
    [sender.navigationController pushViewController:controller animated:YES];
   
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
