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

#import "NSArray+Collect.h"
#import "NSDate+FormattedDate.h"

@implementation HRVitalAppletTile {
@private
    UIPopoverController * __strong popoverController;
}

@synthesize leftTitleLabel = __leftTitleLabel;
@synthesize leftValueLabel = __leftValueLabel;
@synthesize middleTitleLabel = __middleTitleLabel;
@synthesize middleValueLabel = __middleValueLabel;
@synthesize rightTitleLabel = __rightTitleLabel;
@synthesize rightValueLabel = __rightValueLabel;
@synthesize sparkLineView   = __sparkLineView;
@synthesize titleLabel = __titleLabel;

#pragma mark object methods

- (void)tileDidLoad {
    [super tileDidLoad];
    self.sparkLineView.backgroundColor = [UIColor whiteColor];
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
    if (popoverController == nil) {
        popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
    }
    else { popoverController.contentViewController = navController; }
    [popoverController
     presentPopoverFromRect:rect
     inView:sender.view
     permittedArrowDirections:UIPopoverArrowDirectionAny
     animated:YES];
}

#pragma mark - notifications

- (void)applicationDidEnterBackground {
    [popoverController dismissPopoverAnimated:NO];
}

@end
