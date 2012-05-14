//
//  HRWebViewAppletTile.m
//  HReader
//
//  Created by Marshall Huss on 5/14/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRWebViewAppletTile.h"

@implementation HRWebViewAppletTile

- (void)tileDidLoad {
    [super tileDidLoad];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.bounds];
    webView.userInteractionEnabled = NO;
    webView.delegate = self;
    webView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    NSString *tileURL = [self.userInfo objectForKey:@"tile_url"];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tileURL]]];
    
    [self addSubview:webView];
}

- (void)didReceiveTap:(UIViewController *)sender inRect:(CGRect)rect {
    UIViewController *controller = [[UIViewController alloc] init];
    controller.title = [self.userInfo objectForKey:@"display_name"];

    UIWebView *webView = [[UIWebView alloc] initWithFrame:controller.view.bounds];
    webView.delegate = self;
    webView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    NSString *fullscreenURL = [self.userInfo objectForKey:@"fullscreen_url"];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:fullscreenURL]]];
    
    [controller.view addSubview:webView];
    [sender.navigationController pushViewController:controller animated:YES];   
}


@end
