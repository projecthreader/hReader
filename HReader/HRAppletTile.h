//
//  HRAppletTile.h
//  HReader
//
//  Created by Caleb Davenport on 4/10/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>


@class HRMPatient;
/*
 
 
 
 */
@interface HRAppletTile : UIView


/*
 
 
 */
@property (strong, nonatomic) HRMPatient *patient;

/*
 
 
 */
@property (strong, nonatomic) NSDictionary *userInfo;

/*
 
 
 
 */
+ (instancetype)tileWithPatient:(HRMPatient *)patient userInfo:(NSDictionary *)userInfo;

/*
 
 
 
 */
- (void)didReceiveTap:(UIViewController *)sender inRect:(CGRect)rect;


/*
 
 
 
 */
- (void)tileDidLoad;

@end
