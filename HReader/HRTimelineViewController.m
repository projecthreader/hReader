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

@interface HRTimelineViewController ()
- (void)reloadData;
- (void)reloadDataAnimated;
@end

@implementation HRTimelineViewController

@synthesize scrollView  = __scrollView;
@synthesize webView     = __webView;
@synthesize headerView  = __headerView;
@synthesize nameLabel   = __nameLabel;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [__scrollView release];
    [__headerView release];
    [__webView release];
    [__nameLabel release];
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
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(patientChanged:) 
                                                     name:HRPatientDidChangeNotification 
                                                   object:nil];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HRPatientSwipeViewController *patientSwipeViewController = (HRPatientSwipeViewController *)[self.childViewControllers objectAtIndex:0];
    patientSwipeViewController.selectedPatient = [HRConfig selectedPatient];
    [self.headerView addSubview:patientSwipeViewController.view];
    
    
    self.headerView.backgroundColor = [UIColor clearColor];    
}

- (void)viewDidUnload {
    self.scrollView = nil;
    self.headerView = nil;
    self.webView = nil;

    [self setNameLabel:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - NSNotificationCenter

- (void)patientChanged:(NSNotification *)notif {
    [self reloadDataAnimated];
}

- (void)reloadDataAnimated {
    [UIView animateWithDuration:0.4 animations:^{
        self.nameLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self reloadData];
        
        [UIView animateWithDuration:0.4 animations:^{
            self.nameLabel.alpha = 1.0;
        }];
    }];   
}

- (void)reloadData {
    HRPatient *patient = [HRConfig selectedPatient];
    self.nameLabel.text = [patient.name uppercaseString];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"hReader" 
                                                     ofType:@"html"
                                                inDirectory:@"timeline/hReader"];
    NSLog(@"Path: %@", path);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
    [self.webView loadRequest:request];
}

@end
