//
//  HRPatientSwipeControl.h
//  HReader
//
//  Created by Marshall Huss on 2/15/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPatientSwipeControl : UIControl  <UIScrollViewDelegate>

@property (copy, nonatomic) NSArray *patients;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic) NSInteger selectedIndex;

+ (HRPatientSwipeControl *)controlWithOwner:(id)owner options:(NSDictionary *)options;

- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated;
- (IBAction)pageControlValueChanged:(UIPageControl *)sender;

@end
