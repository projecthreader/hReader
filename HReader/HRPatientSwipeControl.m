//
//  HRPatientSwipeControl.m
//  HReader
//
//  Created by Marshall Huss on 2/15/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRPatientSwipeControl.h"
#import "HRAppDelegate.h"
#import "HRMPatient.h"

#import "HRPeoplePickerViewController.h"

@interface HRPatientSwipeControl ()
@property (nonatomic, copy, readwrite) NSArray *patients;
- (void)postChangeNotification;
- (void)patientChanged:(NSNotification *)notif;
@end

@implementation HRPatientSwipeControl

@synthesize patients = __patients;
@synthesize scrollView = __scrollView;
@synthesize pageControl = __pageControl;

#pragma mark - class methods

+ (id)controlWithOwner:(id)owner options:(NSDictionary *)options target:(id)target action:(SEL)action {
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
    NSArray *array = [nib instantiateWithOwner:owner options:options];
    NSAssert([array count] == 1, @"There should only be one top level object");
    HRPatientSwipeControl *control = [array lastObject];
    [control addTarget:target action:action forControlEvents:UIControlEventValueChanged];
    return [array lastObject];
}

#pragma mark - object lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // set frame
    self.frame = CGRectMake(32.0, 15.0, 175.0, 175.0);
    
    // scroll view border
    self.scrollView.layer.cornerRadius = 5.0f;
    self.scrollView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.scrollView.layer.borderWidth = 2.0f;
    
    // self shadow
    self.layer.cornerRadius = 5.0f;
    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.layer.borderWidth = 2.0f;
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOpacity = 0.35f;
    self.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.layer.shadowRadius = 5.0f;
    self.layer.shouldRasterize = YES;
    
    // load initial patients
    NSArray *patients = [HRMPatient patientsInContext:[HRAppDelegate managedObjectContext]];
    HRMPatient *patient = [HRMPatient selectedPatient];
    NSInteger index = [patients indexOfObject:patient];
    self.patients = patients;
    self.page = index;
    
    // watch for notifications
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(patientChanged:)
     name:HRPatientDidChangeNotification
     object:nil];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:HRPatientDidChangeNotification
     object:nil];
    self.scrollView = nil;
    self.pageControl = nil;
    self.patients = nil;
    [super dealloc];
}

#pragma mark - UIPageControl targets

- (IBAction)pageControlValueChanged:(UIPageControl *)sender {
    [self setPage:sender.currentPage animated:YES];
}

#pragma mark - custom accessors

- (NSInteger)page {
    UIScrollView *scrollView = self.scrollView;
    return scrollView.contentOffset.x / scrollView.bounds.size.width;
}

- (void)setPage:(NSInteger)page {
    [self setPage:page animated:NO];
}

- (void)setPage:(NSInteger)page animated:(BOOL)animated {
    UIScrollView *scrollView = self.scrollView;
    [scrollView
     setContentOffset:CGPointMake(scrollView.bounds.size.width * page, 0.0)
     animated:animated];
    if (animated) {
        self.userInteractionEnabled = NO;
    }
}
- (void)setPatients:(NSArray *)patients {
    
    // get new list
    [__patients release];
    __patients = [patients copy];
    
    // calculate sizes
    UIScrollView *scrollView = self.scrollView;
    NSUInteger numberOfPatients = [__patients count];
    CGSize size = self.bounds.size;
    scrollView.contentSize = CGSizeMake(size.width * numberOfPatients, size.height);
    self.pageControl.numberOfPages = numberOfPatients;
    
    // remove all views from the scroll view
    [scrollView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger index, BOOL *stop) {
        [view removeFromSuperview];
    }];
    
    // add views for all patients
    [__patients enumerateObjectsUsingBlock:^(HRMPatient *patient, NSUInteger index, BOOL *stop) {
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:patient.patientImage] autorelease];
        imageView.frame = CGRectMake(size.width * index, 0.0, size.width, size.height);
        [scrollView addSubview:imageView];
        if (index == 0 || index == numberOfPatients - 1) {
            imageView.layer.shadowColor = [[UIColor blackColor] CGColor];
            imageView.layer.shadowOpacity = 0.5f;
            imageView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
            imageView.layer.shadowRadius = 5.0f;
        }
        else {
            [scrollView bringSubviewToFront:imageView];
        }
    }];
    
    // update selected page
    HRMPatient *patient = [HRMPatient selectedPatient];
    NSInteger index = [__patients indexOfObject:patient];
    if (index == NSNotFound) {
        index = 0;
        patient = [patients objectAtIndex:0];
        [HRMPatient setSelectedPatient:patient];
        self.page = index;
        [self postChangeNotification];
    }
    
}

#pragma mark - scroll view delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    // get page
    NSInteger page = self.page;
    self.pageControl.currentPage = page;
    
    // get patient
    HRMPatient *patient = [self.patients objectAtIndex:page];
    if (![patient isEqual:[HRMPatient selectedPatient]]) {
        [HRMPatient setSelectedPatient:patient];
        [TestFlight passCheckpoint:@"Patient Swipe"];
        [self postChangeNotification];
    }
    
    // enable interaction
    self.userInteractionEnabled = YES;
    
}

#pragma mark - notifications

- (void)postChangeNotification {
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:HRPatientDidChangeNotification
     object:self
     userInfo:nil];
}

- (void)patientChanged:(NSNotification *)notif {
    if ([notif object] != self) {
        HRMPatient *patient = [HRMPatient selectedPatient];
        NSInteger index = [self.patients indexOfObject:patient];
        self.page = index;
        self.pageControl.currentPage = self.page;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end
