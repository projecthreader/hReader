//
//  HRTimelineViewController.m
//  HReader
//
//  Created by Marshall Huss on 12/2/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "HRTimelineViewController.h"
#import "HRMPatient.h"
#import "HRPatientSwipeControl.h"

#import "DDXML.h"

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
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // load patient swipe
    HRPatientSwipeControl *swipe = [HRPatientSwipeControl
                                    controlWithOwner:self
                                    options:nil 
                                    target:self
                                    action:@selector(patientChanged:)];
    [self.headerView addSubview:swipe];
    
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

- (void)patientChanged:(id)sender {
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
    
    // vars
    NSURL *URL;
    
    // load patient
    HRMPatient *patient = [HRMPatient selectedPatient];
    self.nameLabel.text = [patient.compositeName uppercaseString];
    URL = [[[NSFileManager defaultManager]
            URLsForDirectory:NSDocumentDirectory
            inDomains:NSUserDomainMask]
           lastObject];
    URL = [URL URLByAppendingPathComponent:@"hReader.xml"];
    NSString *XMLString = [[[[patient timelineXMLDocument] XMLString] copy] autorelease];
    BOOL write = [XMLString writeToURL:URL atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSAssert(write, @"The XML file could not be written");
    
    // load timeline
    URL = [[NSBundle mainBundle]
           URLForResource:@"hReader"
           withExtension:@"html"
           subdirectory:@"timeline/hReader"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [self.webView loadRequest:request];
    
}

@end
