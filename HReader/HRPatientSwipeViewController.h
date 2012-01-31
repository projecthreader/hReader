//
//  HRPatientSwipeViewController.h
//  HReader
//
//  Created by Marshall Huss on 12/7/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HRPatient;

@protocol HRPatientSwipeDelegate <NSObject>
- (void)userDidSwipeToPatient:(HRPatient *)patient;
@end

@interface HRPatientSwipeViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) NSArray *patientsArray;

@property (strong, nonatomic) HRPatient *selectedPatient;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *shadowView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@property (nonatomic) NSInteger lastIndex;

@property (assign, nonatomic) id<HRPatientSwipeDelegate> delegate;

@end
