//
//  UIViewController+SVPanelViewControllerAdditions.m
//  SlidyView
//
//  Created by Caleb Davenport on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+SVPanelViewControllerAdditions.h"

#import "SVPanelViewController.h"

@interface UIViewController (SVPanelViewControllerAdditions_Private)

+ (SVPanelViewController *)panelViewControllerFromViewController:(UIViewController *)controller;

@end

@implementation UIViewController (SVPanelViewControllerAdditions)

- (SVPanelViewController *)panelViewController {
    return [UIViewController panelViewControllerFromViewController:self];
}

@end

@implementation UIViewController (SVPanelViewControllerAdditions_Private)

+ (SVPanelViewController *)panelViewControllerFromViewController:(UIViewController *)controller {
    if (controller == nil) {
        return nil;
    }
    else if ([controller isKindOfClass:[SVPanelViewController class]]) {
        return (id)controller;
    }
    else {
        return [self panelViewControllerFromViewController:controller.parentViewController];
    }
}

@end
