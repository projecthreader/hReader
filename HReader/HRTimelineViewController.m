//
//  HRTimelineViewController.m
//  HReader
//
//  Created by Marshall Huss on 12/2/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "HRTimelineViewController.h"
#import "HRPatientSwipeViewController.h"
#import "HRPatient.h"

@implementation HRTimelineViewController

@synthesize scrollView  = __scrollView;
@synthesize webView     = __webView;
@synthesize headerView  = __headerView;
@synthesize nameLabel = _nameLabel;

- (void)dealloc {
    [__scrollView release];
    [__headerView release];
    [__webView release];
    
    [_nameLabel release];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(patientChanged:) 
                                                 name:HRPatientDidChangeNotification 
                                               object:nil];
    
}

- (void)viewDidUnload {
    self.scrollView = nil;
    self.headerView = nil;
    self.webView = nil;

    [self setNameLabel:nil];
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)patientChanged:(NSNotification *)notif {
    HRPatient *patient = [notif.userInfo objectForKey:HRPatientKey];
    [UIView animateWithDuration:0.4 animations:^{
        self.nameLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.nameLabel.text = [patient.name uppercaseString];
        
        [UIView animateWithDuration:0.4 animations:^{
            self.nameLabel.alpha = 1.0;
        }];
    }];   
}

@end
