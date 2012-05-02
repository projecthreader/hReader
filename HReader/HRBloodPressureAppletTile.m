//
//  HRBloodPressueAppletTile.m
//  HReader
//
//  Created by Marshall Huss on 4/16/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRBloodPressureAppletTile.h"
#import "HRMEntry.h"
#import "HRSparkLineView.h"
#import "HRKeyValueTableViewController.h"

#import "NSDate+FormattedDate.h"
#import "NSArray+Collect.h"

@implementation HRBloodPressureAppletTile {
@private
    UIPopoverController * __strong __popoverController;
    NSArray * __strong __systolicDataPoints;
    NSArray * __strong __diastolicDataPoints;
}

@synthesize resultLabel     = __resultLabel;
@synthesize dateLabel       = __dateLabel;
@synthesize normalLabel     = __normalLabel;

@synthesize sparkLineView   = __sparkLineView;


- (void)tileDidLoad {
    [super tileDidLoad];
    
    __systolicDataPoints = [self.patient vitalSignsWithEntryType:@"systolic blood pressure"];
    __diastolicDataPoints = [self.patient vitalSignsWithEntryType:@"diastolic blood pressure"];

    
    HRMEntry *lastestSystolic = [__systolicDataPoints lastObject];
    HRMEntry *lastestDiastolic = [__diastolicDataPoints lastObject];
    
    // set labels
    self.resultLabel.adjustsFontSizeToFitWidth = YES;
    float lastestSystolicValue = [[lastestSystolic valueForKeyPath:@"value.scalar"] floatValue];
    float lastestDiastolicValue = [[lastestDiastolic valueForKeyPath:@"value.scalar"] floatValue];
    self.resultLabel.text = [NSString stringWithFormat:@"%.0f/%.0f", lastestSystolicValue, lastestDiastolicValue];
    self.dateLabel.text = [lastestSystolic.date shortStyleDate];
    self.dateLabel.adjustsFontSizeToFitWidth = YES;
    
    self.normalLabel.adjustsFontSizeToFitWidth = YES;
    self.normalLabel.text = [NSString stringWithFormat:@"%.0f-%.0f/%.0f-%.0f", [self normalSystolicLow], [self normalSystolicHigh], [self normalDiastolicLow], [self normalDiastolicHigh]];
    
    // sparkline
    HRSparkLineRange systolicRange = HRMakeRange([self normalSystolicLow], [self normalSystolicHigh] - [self normalSystolicLow]);
    HRSparkLineLine *systolicLine = [[HRSparkLineLine alloc] init];
    systolicLine.outOfRangeDotColor = [HRConfig redColor];
    systolicLine.weight = 4.0;
    systolicLine.points = [self sparkLinePointsForDataSet:__systolicDataPoints];
    systolicLine.range = systolicRange;
    
    HRSparkLineRange diastolicRange = HRMakeRange([self normalDiastolicLow], [self normalDiastolicHigh] - [self normalDiastolicLow]);
    HRSparkLineLine *diastolicLine = [[HRSparkLineLine alloc] init];
    diastolicLine.outOfRangeDotColor = [HRConfig redColor];
    diastolicLine.weight = 4.0;
    diastolicLine.points = [self sparkLinePointsForDataSet:__diastolicDataPoints];
    diastolicLine.range = diastolicRange;
    
    
    self.sparkLineView.lines = [NSArray arrayWithObjects:systolicLine, diastolicLine, nil];
    self.sparkLineView.visibleRange = HRMakeRange([self normalDiastolicLow], [self normalSystolicHigh] - [self normalDiastolicLow]);
    
    // display normal value
    float systolicValue = [[lastestSystolic valueForKeyPath:@"value.scalar"] floatValue];
    if ([self isSystolicNormal:systolicValue]) {
        self.resultLabel.textColor = [UIColor blackColor];
    } else {
        self.resultLabel.textColor = [HRConfig redColor];
    }
    
}

- (void)didReceiveTap:(UIViewController *)sender inRect:(CGRect)rect {
    UITableViewController *controller = [[HRKeyValueTableViewController alloc] initWithDataPoints:[self dataPoints]];
    controller.title = @"Blood Pressure";
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
    NSMutableArray *points = [NSMutableArray arrayWithCapacity:[__systolicDataPoints count]];
    [__systolicDataPoints enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(HRMEntry *entry, NSUInteger index, BOOL *stop) {
        
        double systolicValue = [[entry.value objectForKey:@"scalar"] doubleValue];
        double diastolicValue = 0;
        if (index < [__diastolicDataPoints count]) {
            HRMEntry *diastolicEntry = [__diastolicDataPoints objectAtIndex:index];
            diastolicValue = [[diastolicEntry.value objectForKey:@"scalar"] doubleValue];
        }
        
        BOOL isNormal = [self isSystolicNormal:systolicValue];
        UIColor *color = isNormal ? [UIColor blackColor] : [HRConfig redColor];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"%.0f/%.0f", systolicValue, diastolicValue], @"detail",
                                    [entry.date mediumStyleDate], @"title",
                                    color, @"detail_color",
                                    nil];
        [points addObject:dictionary];
    }];
    return [points copy];
}

//- (NSArray *)scalarValuesForEntries:(NSArray *)entries {
//    NSArray *scalarStrings = [__systolicDataPoints valueForKeyPath:@"value.scalar"];
//    NSArray *scalars = [scalarStrings collect:^(id object, NSUInteger idx) {
//        if ([object isKindOfClass:[NSString class]]) {
//            float value = [object floatValue];
//            return [NSNumber numberWithDouble:value];
//        }
//        else {
//            return [NSNumber numberWithDouble:0.0];
//        }
//    }];
//    return scalars;
//}

- (NSArray *)sparkLinePointsForDataSet:(NSArray *)dataSet {
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:[dataSet count]];
    [dataSet enumerateObjectsUsingBlock:^(HRMEntry *entry, NSUInteger index, BOOL *stop) {
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



- (double)normalSystolicLow {
    return 90.0;
}
- (double)normalSystolicHigh {
    return 120.0;
}

- (double)normalDiastolicLow {
    return 60.0;
}

- (double)normalDiastolicHigh {
    return 80.0;
}

- (BOOL)isSystolicNormal:(double)systolic {
    return (systolic >= [self normalSystolicLow] && systolic <= [self normalSystolicHigh]);
}

- (BOOL)isDiastolicNormal:(double)diastolic {
//    return (diastolic >= [self normalDiastolicLow] && systolic <= [self normalDiastolicHigh]);
    return YES;
}

@end
