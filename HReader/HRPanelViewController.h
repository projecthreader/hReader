//
//  HRPanelViewController.h
//  HReader
//
//  Created by Caleb Davenport on 10/11/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HRPanelViewController;

@interface UIViewController (HRPanelViewControllerAdditions)

@property (nonatomic, readonly) HRPanelViewController *panelViewController;

@end

@interface HRPanelViewController : UIViewController

@property (nonatomic, strong) UIViewController *mainViewController;
@property (nonatomic, strong) UIViewController *leftAccessoryViewController;
@property (nonatomic, strong) UIViewController *rightAccessoryViewController;
@property (nonatomic, assign) CGFloat leftAccessoryViewWidth;
@property (nonatomic, assign) CGFloat rightAccessoryViewWidth;

- (void)showLeftAccessoryViewController:(BOOL)animated;
- (void)showRightAccessoryViewController:(BOOL)animated;
- (void)showMainViewController:(BOOL)animated;

@end
