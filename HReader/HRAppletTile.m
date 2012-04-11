//
//  HRAppletTile.m
//  HReader
//
//  Created by Caleb Davenport on 4/10/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRAppletTile.h"

@interface HRAppletTile ()

- (void)commonInit;

@end

@implementation HRAppletTile

#pragma mark - class methods

+ (instancetype)tile {
    return [[self alloc] init];
}

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIApplicationDidEnterBackgroundNotification
     object:nil];
}

- (void)commonInit {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didEnterBackground:)
     name:UIApplicationDidEnterBackgroundNotification
     object:nil];
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
