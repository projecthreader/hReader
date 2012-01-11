//
//  HRTimelineViewController.m
//  HReader
//
//  Created by Marshall Huss on 12/2/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "HRTimelineViewController.h"
#import "HRPatientSwipeViewController.h"


@implementation HRTimelineViewController

@synthesize scrollView  = __scrollView;
@synthesize webView     = __webView;
@synthesize headerView  = __headerView;

- (void)dealloc {
    [__scrollView release];
    [__headerView release];
    [__webView release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Timeline";
        
        HRPatientSwipeViewController *patientSwipeViewController = [[HRPatientSwipeViewController alloc] initWithNibName:nil bundle:nil];
        [self addChildViewController:patientSwipeViewController];
        patientSwipeViewController.patientsArray = [HRConfig patients];
        [patientSwipeViewController release];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HRPatientSwipeViewController *patientSwipeViewController = (HRPatientSwipeViewController *)[self.childViewControllers objectAtIndex:0];
    [self.headerView addSubview:patientSwipeViewController.view];
    
    
    self.headerView.backgroundColor = [UIColor clearColor];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"hReader" 
                                                     ofType:@"html"
                                                inDirectory:@"timeline/hReader"];
    NSLog(@"Path: %@", path);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
    [self.webView loadRequest:request];
}

- (void)viewDidUnload {
    self.scrollView = nil;
    self.headerView = nil;
    self.webView = nil;

    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
