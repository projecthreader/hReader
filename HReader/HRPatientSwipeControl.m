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

//static NSString * const HRPatientDidChangeNotification = @"HRPatientDidChange";

@interface HRPatientSwipeControl ()
@property (copy, nonatomic, readwrite) NSArray *patients;
@property (assign, nonatomic, readwrite) NSInteger selectedIndex;
- (void)postChangeNotification;
- (void)patientChanged:(NSNotification *)notif;
@end

@implementation HRPatientSwipeControl

@synthesize patients        = __patients;
@synthesize scrollView      = __scrollView;
@synthesize pageControl     = __pageControl;
@synthesize selectedIndex   = __selectedIndex;

#pragma mark - class methods
+ (HRPatientSwipeControl *)controlWithOwner:(id)owner options:(NSDictionary *)options target:(id)target action:(SEL)action {
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
    NSArray *array = [nib instantiateWithOwner:owner options:options];
    NSAssert([array count] == 1, @"There is more than one top level object");
    HRPatientSwipeControl *control = [array lastObject];
    [control addTarget:target action:action forControlEvents:UIControlEventValueChanged];
    return [array lastObject];
}

#pragma mark - object methods
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
    self.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    self.layer.shadowRadius = 5.0f;
    
    // load initial patients
    NSArray *patients = [HRMPatient patientsInContext:[HRAppDelegate managedObjectContext]];
    HRMPatient *patient = [HRMPatient selectedPatient];
    NSUInteger index = [patients indexOfObject:patient];
    self.patients = patients;
    self.selectedIndex = index;
    
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
}

#pragma mark - custom setters
- (void)setPatients:(NSArray *)patients {
    [__patients release];
    __patients = [patients copy];
    CGSize size = self.bounds.size;
    self.scrollView.contentSize = CGSizeMake(size.width * [__patients count], size.height);
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [__patients enumerateObjectsUsingBlock:^(HRMPatient *patient, NSUInteger idx, BOOL *stop) {
        UIImageView *patientImageView = [[[UIImageView alloc] initWithImage:patient.patientImage] autorelease];
        patientImageView.frame = CGRectMake(size.width * idx, 0.0, size.width, size.height);
        [self.scrollView addSubview:patientImageView];
        if (idx == 0 || idx == [__patients count] - 1) {
            patientImageView.layer.shadowColor = [[UIColor blackColor] CGColor];
            patientImageView.layer.shadowOpacity = 0.5f;
            patientImageView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
            patientImageView.layer.shadowRadius = 5.0f;
        }
        else {
            [self.scrollView bringSubviewToFront:patientImageView];
        }
    }];
    self.pageControl.numberOfPages = [__patients count];
}
- (void)setSelectedIndex:(NSInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex animated:NO];
}
- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated {
    __selectedIndex = index;
    [self.scrollView
     setContentOffset:CGPointMake(self.scrollView.bounds.size.width * __selectedIndex, 0.0)
     animated:animated];
    self.pageControl.currentPage = index;
}

#pragma mark - UIPageControl targets
- (IBAction)pageControlValueChanged:(UIPageControl *)sender {
    [self setSelectedIndex:sender.currentPage animated:YES];
}

#pragma mark - scroll view delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:scrollView];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSInteger index = self.scrollView.contentOffset.x / self.scrollView.bounds.size.width;
    if (index != self.selectedIndex) {
        self.pageControl.currentPage = index;
        HRMPatient *patient = [self.patients objectAtIndex:index];
        [HRMPatient setSelectedPatient:patient];
        self.selectedIndex = index;
        [TestFlight passCheckpoint:@"Patient Swipe"];
        [self postChangeNotification];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark - notifications
- (void)postChangeNotification {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:HRPatientDidChangeNotification
     object:self
     userInfo:nil];
}
- (void)patientChanged:(NSNotification *)notif {
    if ([notif object] != self) {
        HRMPatient *patient = [HRMPatient selectedPatient];
        self.selectedIndex = [self.patients indexOfObject:patient];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end
