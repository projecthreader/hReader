//
//  HRPatientSwipeControl.m
//  HReader
//
//  Created by Marshall Huss on 2/15/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRPatientSwipeControl.h"

#import "HRPatient.h"
#import "HRMPatient.h"

@implementation HRPatientSwipeControl

@synthesize patients        = __patients;
@synthesize scrollView      = __scrollView;
@synthesize pageControl     = __pageControl;
@synthesize selectedIndex   = __selectedIndex;

#pragma mark - class methods
+ (HRPatientSwipeControl *)controlWithOwner:(id)owner options:(NSDictionary *)options {
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
    NSArray *array = [nib instantiateWithOwner:owner options:options];
    NSAssert([array count] == 1, @"There is more than one top level object");
    return [array lastObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // shadow
    self.layer.cornerRadius = 5.0f;
    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.layer.borderWidth = 2.0f;
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOpacity = 0.5f;
    self.layer.shadowOffset = CGSizeMake(8.0f, 7.0f);
    self.layer.shadowRadius = 5.0f;
    
//    NSArray *patients = [HRMPatient patients];
    
}

#pragma mark - custom setters
- (void)setPatients:(NSArray *)patients {
    [__patients release];
    __patients = [patients copy];
    CGSize size = self.bounds.size;
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [__patients enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        HRPatient *patient = (HRPatient *)obj;
        UIImageView *patientImageView = [[UIImageView alloc] initWithImage:patient.image];
        patientImageView.frame = CGRectMake(size.width * idx, 0.0, size.width, size.height);
        [self.scrollView addSubview:patientImageView];
        [patientImageView release];
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
        HRPatient *patient = [self.patients objectAtIndex:index];
        [HRConfig setSelectedPatient:patient];
//        [self postNotificationWithPatient:patient];
        self.selectedIndex = index;
//        self.lastIndex = index;
//        [TestFlight passCheckpoint:@"Patient Swipe"];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end
