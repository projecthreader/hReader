//
//  UIApplication+hReaderAdditions.m
//  HReader
//
//  Created by Caleb Davenport on 11/5/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "UIApplication+hReaderAdditions.h"

static NSUInteger HRNetworkOperationCount = 0;

@implementation UIApplication (hReaderAdditions)

- (void)hr_updateNetworkActivityIndicator {
    [self setNetworkActivityIndicatorVisible:(HRNetworkOperationCount > 0)];
}

- (void)hr_pushNetworkOperation {
    HRNetworkOperationCount++;
    [self hr_updateNetworkActivityIndicator];
}

- (void)hr_popNetworkOperation {
    if (HRNetworkOperationCount > 0) {
        HRNetworkOperationCount--;
    }
    [self hr_updateNetworkActivityIndicator];
}

@end
