//
//  HRVitalView.m
//  HReader
//
//  Created by Marshall Huss on 2/8/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRVitalAppletTile.h"
#import "HRKeyValueTableViewController.h"
#import "HRSparkLineView.h"

#import "NSDate+FormattedDate.h"

@implementation HRVitalAppletTile {
    UIPopoverController *_popoverController;
}

#pragma mark object methods

- (void)tileDidLoad {
    [super tileDidLoad];
    self.sparkLineView.backgroundColor = [UIColor whiteColor];
    _patient = [self.userInfo objectForKey:@"__private_patient__"];
}

- (NSArray *)dataForKeyValueTable {
    return nil;
}

- (NSString *)titleForKeyValueTable {
    return [self.titleLabel.text capitalizedString];
}

- (NSArray *)dataForSparkLineView {
    return nil;
}

#pragma mark - gestures

- (void)didReceiveTap:(UIViewController *)sender inRect:(CGRect)rect {
    UITableViewController *controller = [[HRKeyValueTableViewController alloc] initWithDataPoints:[self dataForKeyValueTable]];
    controller.title = [self titleForKeyValueTable];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    if (_popoverController == nil) {
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
    }
    else { _popoverController.contentViewController = navController; }
    [_popoverController
     presentPopoverFromRect:rect
     inView:sender.view
     permittedArrowDirections:UIPopoverArrowDirectionAny
     animated:YES];
}

#pragma mark - notifications

- (void)applicationDidEnterBackground {
    [_popoverController dismissPopoverAnimated:NO];
}

@end
