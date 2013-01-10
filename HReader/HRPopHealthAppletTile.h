//
//  HRPopHealthAppletTile.h
//  HReader
//
//  Created by Adam Goldstein on 11/26/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRWebViewAppletTile.h"

@interface HRPopHealthAppletTile : HRWebViewAppletTile

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;

@end
