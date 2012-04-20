//
//  HRTimelineViewController.m
//  HReader
//
//  Created by Marshall Huss on 12/2/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "HRTimelineViewController.h"
#import "HRMPatient.h"
#import "HRPatientSwipeControl.h"
#import "SVPanelViewController.h"
#import "HRPeoplePickerViewController.h"

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
@synthesize patientImageView = __patientImageView;


- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:HRPatientDidChangeNotification
     object:nil];
    
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
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(patientDidChange:)
         name:HRPatientDidChangeNotification
         object:nil];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CALayer *layer = self.patientImageView.layer;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOpacity = 0.35;
    layer.shadowOffset = CGSizeMake(0.0, 1.0);
    layer.shadowRadius = 5.0;
    layer.shouldRasterize = YES;
    layer.rasterizationScale = [[UIScreen mainScreen] scale];

    // load patient swipe
//    HRPatientSwipeControl *swipe = [HRPatientSwipeControl
//                                    controlWithOwner:self
//                                    options:nil 
//                                    target:self
//                                    action:@selector(patientChanged:)];
//    [self.headerView addSubview:swipe];
    
    self.headerView.backgroundColor = [UIColor clearColor];    
    
    // swipe gesture
    {
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didReceiveRightSwipe:)];
        swipeGesture.numberOfTouchesRequired = 1;
        swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
        [self.patientImageView addGestureRecognizer:swipeGesture];
    }
    {
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didReceiveLeftSwipe:)];
        swipeGesture.numberOfTouchesRequired = 1;
        swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.patientImageView addGestureRecognizer:swipeGesture];
    }
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

- (void)patientDidChange:(NSNotification *)sender {
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
    HRMPatient *patient = [(id)self.panelViewController.leftAccessoryViewController selectedPatient];
    self.patientImageView.image = [patient patientImage];

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


#pragma mark - gestures

- (void)didReceiveLeftSwipe:(UISwipeGestureRecognizer *)swipe {
    if (swipe.state == UIGestureRecognizerStateRecognized) {
        [(id)self.panelViewController.leftAccessoryViewController selectNextPatient];
    }
}
- (void)didReceiveRightSwipe:(UISwipeGestureRecognizer *)swipe {
    if (swipe.state == UIGestureRecognizerStateRecognized) {
        [(id)self.panelViewController.leftAccessoryViewController selectPreviousPatient];
    }
}

@end
