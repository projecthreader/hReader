//
//  SVViewController.h
//  SlidyView
//
//  Created by Caleb Davenport on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIViewController+SVPanelViewControllerAdditions.h"

@interface SVPanelViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIViewController *mainViewController;
@property (nonatomic, strong) IBOutlet UIViewController *leftAccessoryViewController;
@property (nonatomic, strong) IBOutlet  UIViewController *rightAccessoryViewController;

- (void)exposeLeftAccessoryViewController:(BOOL)animated;
- (void)exposeRightAccessoryViewController:(BOOL)animated;
- (void)hideAccessoryViewControllers:(BOOL)animated;

@end
