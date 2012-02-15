//
//  HRPatientSwipeControl.h
//  HReader
//
//  Created by Marshall Huss on 2/15/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPatientSwipeControl : UIControl  <UIScrollViewDelegate>

@property (copy, nonatomic, readonly) NSArray *patients;
@property (assign, nonatomic, readonly) NSInteger selectedIndex;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

+ (HRPatientSwipeControl *)controlWithOwner:(id)owner options:(NSDictionary *)options target:(id)target action:(SEL)action;

- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated;
- (IBAction)pageControlValueChanged:(UIPageControl *)sender;

@end
