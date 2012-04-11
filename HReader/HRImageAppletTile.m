//
//  HRImageAppletTile.m
//  HReader
//
//  Created by Marshall Huss on 4/11/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRImageAppletTile.h"

@implementation HRImageAppletTile {
    NSString * __strong __title;
    UIImage * __strong __tileImage;
    UIImage * __strong __fullScreenImage;
}

#pragma mark - class methods

+ (HRAppletTile *)tile {
    return [[self alloc] init];
}

#pragma mark object methods

- (void)setTitle:(NSString *)title tileImage:(UIImage *)tileImage fullScreenImage:(UIImage *)fullScreenImage {
    __title = [title copy];
    __tileImage = tileImage;
    __fullScreenImage = fullScreenImage;
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:__tileImage];
    imageView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    imageView.frame = self.bounds;
    [self addSubview:imageView];
}

#pragma mark - gestures

- (void)didReceiveTap:(UIViewController *)sender inRect:(CGRect)rect {
    UIViewController *controller = [[UIViewController alloc] init];
    controller.title = __title;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:__fullScreenImage];
    imageView.frame = controller.view.bounds;
    imageView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [controller.view addSubview:imageView];
    [sender.navigationController pushViewController:controller animated:YES];
}

@end
