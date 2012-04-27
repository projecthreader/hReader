//
//  HRImageAppletTile.m
//  HReader
//
//  Created by Marshall Huss on 4/11/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRImageAppletTile.h"

@implementation HRImageAppletTile

- (void)tileDidLoad {
    [super tileDidLoad];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImage *tileImage = [UIImage imageNamed:[self.userInfo objectForKey:@"tile_image"]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:tileImage];
    imageView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    imageView.frame = self.bounds;
    [self addSubview:imageView];
}

- (void)didReceiveTap:(UIViewController *)sender inRect:(CGRect)rect {
    NSString *fullScreenName = [self.userInfo objectForKey:@"fullscreen_image"];
    UIImage *fullScreenImage = [UIImage imageNamed:fullScreenName];
    if (fullScreenImage) {
        UIViewController *controller = [[UIViewController alloc] init];
        controller.title = [self.userInfo objectForKey:@"display_name"];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:fullScreenImage];
        imageView.frame = controller.view.bounds;
        imageView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        [controller.view addSubview:imageView];
        [sender.navigationController pushViewController:controller animated:YES];   
    }
}

@end
