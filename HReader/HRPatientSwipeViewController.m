//
//  HRPatientSwipeViewController.m
//  HReader
//
//  Created by Marshall Huss on 12/7/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRPatientSwipeViewController.h"
#import "HRPatient.h"

@interface HRPatientSwipeViewController ()
- (void)postNotificationWithPatient:(HRPatient *)patient;
@end

@implementation HRPatientSwipeViewController

@synthesize patientsArray   = __patientArray;
@synthesize selectedPatient = __selectedPatient;
@synthesize scrollView      = __scrollView;
@synthesize shadowView      = __shadowView;
@synthesize pageControl     = __pageControl;
@synthesize lastIndex       = __lastIndex;
@synthesize delegate        = __delegate;

- (void)dealloc {
    [__patientArray release];
    [__scrollView release];
    [__shadowView release];
    [__pageControl release];
    __delegate = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = CGRectMake(32, 15, 175, 175);
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(175 * [self.patientsArray count], 175);
    self.scrollView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    NSInteger index = [self.patientsArray indexOfObject:self.selectedPatient];
    self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width * index, 0);
    
    [self.patientsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        HRPatient *patient = (HRPatient *)obj;
        UIImageView *patientImageView = [[UIImageView alloc] initWithImage:patient.image];
        patientImageView.frame = CGRectMake(175 * idx, 0, 175, 175);
        [self.scrollView addSubview:patientImageView];
        [patientImageView release];
    }];
    
    [self.view addSubview:self.scrollView];
    
    // Page control
    self.pageControl.numberOfPages = [self.patientsArray count];
    [self.pageControl addTarget:self action:@selector(pageControlTapped) forControlEvents:UIControlEventValueChanged];
    [self.view bringSubviewToFront:self.pageControl];

    
    // Rounded corners
    self.scrollView.layer.masksToBounds = YES;
    self.scrollView.layer.cornerRadius = 5.0f;
    
    // Border
    self.scrollView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.scrollView.layer.borderWidth = 2.0f;
    
    // Shadows
    self.shadowView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.shadowView.layer.shadowOpacity = 0.5f;
    self.shadowView.layer.shadowOffset = CGSizeMake(8.0f, 7.0f);
    self.shadowView.layer.shadowRadius = 5.0f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(patientChanged:) name:HRPatientDidChangeNotification object:nil];
//    [self postNotificationWithPatient:[self.patientsArray objectAtIndex:0]];
}


- (void)viewDidUnload {
    [super viewDidUnload];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.scrollView = nil;
    self.shadowView = nil;
    self.pageControl = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSInteger index = self.scrollView.contentOffset.x / self.scrollView.bounds.size.width;

    if (index != self.lastIndex) {
        self.pageControl.currentPage = index;
        HRPatient *patient = [self.patientsArray objectAtIndex:index];
        [HRConfig setSelectedPatient:patient];
        [self postNotificationWithPatient:patient];
        self.lastIndex = index;
        [TestFlight passCheckpoint:@"Patient Swipe"];
    }
}

#pragma mark - UIPageControl targets

- (void)pageControlTapped {
    [self.scrollView setContentOffset:CGPointMake(self.pageControl.currentPage * self.scrollView.bounds.size.width, 0) animated:YES];
}

#pragma mark - private methods

- (void)postNotificationWithPatient:(HRPatient *)patient {
    [[NSNotificationCenter defaultCenter] postNotificationName:HRPatientDidChangeNotification 
                                                        object:self 
                                                      userInfo:[NSDictionary dictionaryWithObject:patient forKey:HRPatientKey]];           
}

- (void)patientChanged:(NSNotification *)notif {
    if ([notif object] != self) {
        HRPatient *patient = [notif.userInfo objectForKey:HRPatientKey];
        NSUInteger index = [self.patientsArray indexOfObject:patient];
        self.scrollView.contentOffset = CGPointMake(index * self.scrollView.bounds.size.width, 0);
        self.pageControl.currentPage = index;
    }
}

@end
