//
//  HRAppletTile.h
//  HReader
//
//  Created by Caleb Davenport on 4/10/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *HRAppletTilePatientIdentityTokenKey;

/*
 
 
 
 */
@interface HRAppletTile : UIView

/*
 
 Creates a new applet with the given userInfo dictionary. You should never
 execute this method directly.
 
 */
+ (id)tileWithUserInfo:(NSDictionary *)userInfo;

/*
 
 Called when the tile has been fully loaded. At this point all properties have
 been set and you take any additional steps to configure the tile.
 
 */
- (void)tileDidLoad;

/*
 
 Token that is unique to each patient in the database. You cannot determine
 which locally stored patient this token belongs to. It is simply here to help
 you pull your own records and store data based on this token.
 
 */
@property (nonatomic, readonly) NSString *patientIdentityToken;

/*
 
 Access the configuration options that you provided for this applet tile in
 HReaderApplets.plist
 
 */
@property (nonatomic, readonly) NSDictionary *userInfo;

/*
 
 Tells an applet tile that it has been tapped by the user. Use this to push
 a new view controller onto the navigation controller or show a popover.
 
 */
- (void)didReceiveTap:(UIViewController *)sender inRect:(CGRect)rect;

/*
 
 Since the application performs a few cleanup tasks when the app goes into
 the background, we require all applets to perform any cleanup such as hiding
 popovers or action sheets here.
 
 */
- (void)applicationDidEnterBackground;

@end
