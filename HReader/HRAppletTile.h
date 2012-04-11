//
//  HRAppletTile.h
//  HReader
//
//  Created by Caleb Davenport on 4/10/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 
 
 
 */
@interface HRAppletTile : UIView

/*
 
 
 
 */
+ (instancetype)tile;

/*
 
 
 
 */
- (void)didReceiveTap:(UIViewController *)sender inRect:(CGRect)rect;

@end
