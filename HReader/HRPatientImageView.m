//
//  HRPatientImageView.m
//  HReader
//
//  Created by Marshall Huss on 4/20/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRPatientImageView.h"
#import "HRPeoplePickerViewController.h"

NSInteger const HRControlEventSwipeLeft = 0x0F000001;
NSInteger const HRControlEventSwipeRight = 0x0F000002;

@implementation HRPatientImageView {
@private
    UIImageView *imageView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        UISwipeGestureRecognizer *gesture;
        
        gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didReceiveRightSwipe:)];
        gesture.numberOfTouchesRequired = 1;
        gesture.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:gesture];
        
        gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didReceiveLeftSwipe:)];
        gesture.numberOfTouchesRequired = 1;
        gesture.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:gesture];
        
        imageView = [[UIImageView alloc] initWithImage:nil];
        imageView.layer.shadowColor = [[UIColor blackColor] CGColor];
        imageView.layer.shadowOpacity = 0.35;
        imageView.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        imageView.layer.shadowRadius = 5.0;
        imageView.layer.shouldRasterize = YES;
        imageView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [imageView setFrame:[self bounds]];
}

- (void)setImage:(UIImage *)image {
    imageView.image = image;
}

- (UIImage *)image {
    return imageView.image;
}

- (void)didReceiveLeftSwipe:(UISwipeGestureRecognizer *)swipe {
    if (swipe.state == UIGestureRecognizerStateRecognized) {
        [self sendActionsForControlEvents:HRControlEventSwipeLeft];
    }
}
- (void)didReceiveRightSwipe:(UISwipeGestureRecognizer *)swipe {
    if (swipe.state == UIGestureRecognizerStateRecognized) {
        [self sendActionsForControlEvents:HRControlEventSwipeRight];
    }
}

@end
