//
//  HRAppletTile.m
//  HReader
//
//  Created by Caleb Davenport on 4/10/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRAppletTile.h"

@implementation HRAppletTile

#pragma mark - view lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(didEnterBackground:)
         name:UIApplicationDidEnterBackgroundNotification
         object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - gestures

- (void)didReceiveTap:(UIViewController *)sender inRect:(CGRect)rect {
    NSLog(@"%@: Should be implemented", _cmd);
}

#pragma mark - notifs

- (void)didEnterBackground:(NSNotification *)notif {
    NSLog(@"%@: Should be implemented", _cmd);
}

@end
