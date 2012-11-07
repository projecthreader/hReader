//
//  HRTimelinePOSTURLProtocol.m
//  HReader
//
//  Created by Caleb Davenport on 11/5/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRTimelinePOSTURLProtocol.h"

@implementation HRTimelinePOSTURLProtocol

+ (void)load {
    @autoreleasepool {
        [NSURLProtocol registerClass:self];
    }
}

+ (NSURL *)indexURL {
    static NSURL *URL = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        URL = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html" subdirectory:@"timeline-angular/app"];
    });
    return URL;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if (![[request HTTPMethod] isEqualToString:@"POST"]) {
        return NO;
    }
    static NSString * const location = @"http://hreader.local/timeline.json";
    NSURL *URL = [request URL];
    if ([[URL absoluteString] rangeOfString:location].location == 0) {
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    id<NSURLProtocolClient> client = [self client];
    
    // send redirect
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[HRTimelinePOSTURLProtocol indexURL]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc]
                                   initWithURL:[[self request] URL]
                                   statusCode:302
                                   HTTPVersion:@"HTTP/1.1"
                                   headerFields:nil];
    [client URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    
}

- (void)stopLoading {
    
}

@end
