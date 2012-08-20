//
//  HRAppletTile.m
//  HReader
//
//  Created by Caleb Davenport on 4/10/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRAppletTile.h"

NSString *HRAppletTilePatientIdentityTokenKey = @"HRAppletTilePatientIdentityToken";

@implementation HRAppletTile

#pragma mark - class methods

+ (id)tileWithUserInfo:(NSDictionary *)userInfo {
    HRAppletTile *tile = nil;
    
    // load the tile
    NSString *name = [userInfo objectForKey:@"nib_name"];
    if (name == nil) {
        name = NSStringFromClass(self);
    }
    NSURL *URL = [[NSBundle mainBundle] URLForResource:name withExtension:@"nib"];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    if (data) {
        UINib *nib = [UINib nibWithData:data bundle:nil];
        tile = [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    }
    else {
        tile = [[self alloc] init];
    }
    
    // configure
    [[NSNotificationCenter defaultCenter]
     addObserver:tile
     selector:@selector(applicationDidEnterBackground)
     name:UIApplicationDidEnterBackgroundNotification
     object:nil];
    tile->_userInfo = [userInfo copy];
    [tile tileDidLoad];
    
    return tile;
}

#pragma mark - object methods

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIApplicationDidEnterBackgroundNotification
     object:nil];
}

- (NSString *)patientIdentityToken {
    return [self.userInfo objectForKey:HRAppletTilePatientIdentityTokenKey];
}

# pragma mark - tile lifecycle

- (void)tileDidLoad {
    
}

#pragma mark - gestures

- (void)didReceiveTap:(UIViewController *)sender inRect:(CGRect)rect {
    
}

#pragma mark - notifications

- (void)applicationDidEnterBackground {
    
}

@end
