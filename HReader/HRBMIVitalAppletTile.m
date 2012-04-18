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
- (NSArray *)scalarValuesForEntries:(NSArray *)entries;
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
    self.sparkLineView.rangeOverlayLowerLimit = [NSNumber numberWithDouble:[self normalLow]];
    self.sparkLineView.rangeOverlayUpperLimit = [NSNumber numberWithDouble:[self normalHigh]];
    self.sparkLineView.dataValues = [self scalarValuesForEntries:__dataPoints];

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

- (NSArray *)scalarValuesForEntries:(NSArray *)entries {
    NSArray *scalarStrings = [__dataPoints valueForKeyPath:@"value.scalar"];
    NSArray *scalars = [scalarStrings collect:^(id object, NSUInteger idx) {
        if ([object isKindOfClass:[NSString class]]) {
            float value = [object floatValue];
            return [NSNumber numberWithDouble:value];
        }
        else {
            return [NSNumber numberWithDouble:0.0];
        }
    }];
    return scalars;
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
