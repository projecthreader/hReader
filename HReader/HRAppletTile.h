//
//  HRAppletTile.h
//  HReader
//
//  Created by Caleb Davenport on 4/10/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HRMPatient.h"

/*
 
 
 
 */
@interface HRAppletTile : UIView

/*
 
 
 
 */
+ (instancetype)tileWithPatient:(HRMPatient *)patient userInfo:(NSDictionary *)userInfo;

/*
 
 Called when the tile has been fully loaded. At this point all properties have
 been set and you take any additional steps to configure the tile.
 
 */
- (void)tileDidLoad;

/*
 
 Access the patient that is being displayed.
 
 */
@property (nonatomic, readonly) HRMPatient *patient;

/*
 
 Access the configuration options that you provided for this applet tile in
 HReaderApplets.plist
 
 */
@property (nonatomic, readonly) NSDictionary *userInfo;

/*
 
 
 
 */
- (void)didReceiveTap:(UIViewController *)sender inRect:(CGRect)rect;

/*
 
 Since the application performs a few cleanup tasks when the app goes into
 the background, we require all applets to perform any cleanup such as hiding
 popovers or action sheets here.
 
 */
- (void)applicationDidEnterBackground;

@end
