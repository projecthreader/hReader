//
//  HRBMIVitalAppletTile.m
//  HReader
//
//  Created by Marshall Huss on 4/16/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRBMIVitalAppletTile.h"
#import "HRKeyValueTableViewController.h"
#import "HRSparkLineView.h"
#import "HRMEntry.h"


#import "NSDate+FormattedDate.h"
#import "NSArray+Collect.h"

@interface HRBMIVitalAppletTile ()
- (NSArray *)dataPoints;
- (double)normalLow;
- (double)normalHigh;
- (BOOL)isValueNormal:(double)value;
@end

@implementation HRBMIVitalAppletTile {
@private
    UIPopoverController * __strong __popoverController;
    NSArray * __strong __dataPoints;
}

@synthesize resultLabel     = __resultLabel;
@synthesize dateLabel       = __dateLabel;
@synthesize normalLabel     = __normalLabel;

@synthesize sparkLineView   = __sparkLineView;


- (void)tileDidLoad {
    [super tileDidLoad];
    
    __dataPoints = [self.patient vitalSignsWithEntryType:@"BMI"];
    HRMEntry *lastest = [__dataPoints lastObject];
    
    // set labels
    self.resultLabel.adjustsFontSizeToFitWidth = YES;
    float latestValue = [[lastest valueForKeyPath:@"value.scalar"] floatValue];
    self.resultLabel.text = [NSString stringWithFormat:@"%0.1f", latestValue];
    self.dateLabel.text = [lastest.date shortStyleDate];
    self.dateLabel.adjustsFontSizeToFitWidth = YES;
    self.normalLabel.adjustsFontSizeToFitWidth = YES;
    
    // sparkline    
    HRSparkLineRange range = HRMakeRange([self normalLow], [self normalHigh] - [self normalLow]);
    HRSparkLineLine *line = [[HRSparkLineLine alloc] init];
    line.outOfRangeDotColor = [HRConfig redColor];
    line.weight = 4.0;
    line.points = [self sparkLinePoints];
    line.range = range;
    self.sparkLineView.lines = [NSArray arrayWithObject:line];
    self.sparkLineView.visibleRange = range;

    // display normal value
    float val = [[lastest valueForKeyPath:@"value.scalar"] floatValue];
    if ([self isValueNormal:val]) {
        self.resultLabel.textColor = [UIColor blackColor];
    } else {
        self.resultLabel.textColor = [HRConfig redColor];
    }
    
}

- (void)didReceiveTap:(UIViewController *)sender inRect:(CGRect)rect {
    UITableViewController *controller = [[HRKeyValueTableViewController alloc] initWithDataPoints:[self dataPoints]];
    controller.title = @"BMI";
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    if (__popoverController == nil) {
        __popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
    }
    else {
        __popoverController.contentViewController = navController;
    }
    [__popoverController
     presentPopoverFromRect:rect
     inView:sender.view
     permittedArrowDirections:UIPopoverArrowDirectionAny
     animated:YES];
}

#pragma mark - notifications

- (void)applicationDidEnterBackground {
    [__popoverController dismissPopoverAnimated:NO];
}


#pragma mark - private

- (NSArray *)dataPoints {
    NSMutableArray *points = [NSMutableArray arrayWithCapacity:[__dataPoints count]];
    [__dataPoints enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(HRMEntry *entry, NSUInteger index, BOOL *stop) {
        double value = [[entry.value objectForKey:@"scalar"] doubleValue];
        BOOL isNormal = [self isValueNormal:value];
        UIColor *color = isNormal ? [UIColor blackColor] : [HRConfig redColor];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"%0.1f", value], @"detail",
                                    [entry.date mediumStyleDate], @"title",
                                    color, @"detail_color",
                                    nil];
        [points addObject:dictionary];
    }];
    return [points copy];
}

- (NSArray *)sparkLinePoints {
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:[__dataPoints count]];
    [__dataPoints enumerateObjectsUsingBlock:^(HRMEntry *entry, NSUInteger index, BOOL *stop) {
        NSTimeInterval timeInterval = [entry.date timeIntervalSince1970];
        NSString *scalarString = [entry.value objectForKey:@"scalar"];
        CGFloat value = 0.0;
        if ([scalarString isKindOfClass:[NSString class]]) {
            value = [scalarString floatValue];
        }
        HRSparkLinePoint *point = [HRSparkLinePoint pointWithX:timeInterval y:value];
        [points addObject:point];
    }];
    
    return points;
}

- (double)normalLow {
    return 18.5;
}

- (double)normalHigh {
    return 22.9;
}

- (BOOL)isValueNormal:(double)bmi {
    return (bmi >= [self normalLow] && bmi <= [self normalHigh]);
}

@end
