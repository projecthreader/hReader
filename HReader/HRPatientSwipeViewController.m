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
- (void)patientChanged;
@end

@implementation HRPatientSwipeViewController

@synthesize patientsArray   = __patientArray;
@synthesize scrollView      = __scrollView;
@synthesize shadowView      = __shadowView;
@synthesize pageControl     = __pageControl;
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
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(175 * [self.patientsArray count], 175);
    self.scrollView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    [self.patientsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        HRPatient *patient = (HRPatient *)obj;
        UIImageView *patientImageView = [[UIImageView alloc] initWithImage:patient.image];
        patientImageView.frame = CGRectMake(175 * idx, 0, 175, 175);
        [self.scrollView addSubview:patientImageView];
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
}


- (void)viewDidUnload {
    [super viewDidUnload];

    self.scrollView = nil;
    self.shadowView = nil;
    self.pageControl = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSInteger index = self.scrollView.contentOffset.x / self.scrollView.bounds.size.width;
    self.pageControl.currentPage = index;
    HRPatient *patient = [self.patientsArray objectAtIndex:index];
    [[NSNotificationCenter defaultCenter] postNotificationName:HRPatientDidChangeNotification object:self userInfo:[NSDictionary dictionaryWithObject:patient forKey:@"patient"]];
}

#pragma mark - UIPageControl targets

- (void)pageControlTapped {
    [self.scrollView setContentOffset:CGPointMake(self.pageControl.currentPage * self.scrollView.bounds.size.width, 0) animated:YES];
}

#pragma mark - private methods

- (void)patientChanged {
    
}

@end
