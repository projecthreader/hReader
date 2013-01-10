//
//  HRPopHealthAppletTile.m
//  HReader
//
//  Created by Adam Goldstein on 11/26/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRPopHealthAppletTile.h"
#import "HRMPatient.h"

@implementation HRPopHealthAppletTile

- (void)tileDidLoad {
    [super tileDidLoad];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

@end
