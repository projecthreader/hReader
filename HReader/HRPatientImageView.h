//
//  HRPatientImageView.h
//  HReader
//
//  Created by Marshall Huss on 4/20/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSInteger const HRControlEventSwipeLeft;
extern NSInteger const HRControlEventSwipeRight;

@interface HRPatientImageView : UIControl

@property (nonatomic, strong) UIImage *image;

@end
