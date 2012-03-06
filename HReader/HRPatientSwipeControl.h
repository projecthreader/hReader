//
//  HRPatientSwipeControl.h
//  HReader
//
//  Created by Marshall Huss on 2/15/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPatientSwipeControl : UIControl  <UIScrollViewDelegate>

// views
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;

// backing store
@property (nonatomic, copy, readonly) NSArray *patients;

// factory method to create a swipe control
+ (instancetype)controlWithOwner:(id)owner options:(NSDictionary *)options target:(id)target action:(SEL)action;

// set selected with optional animation
- (void)setPage:(NSInteger)page animated:(BOOL)animated;

// page control callback
- (IBAction)pageControlValueChanged:(UIPageControl *)sender;

@end
