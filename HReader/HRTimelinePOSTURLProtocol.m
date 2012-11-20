//
//  HRTimelinePOSTURLProtocol.m
//  HReader
//
//  Created by Caleb Davenport on 11/5/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRTimelinePOSTURLProtocol.h"
#import "HRAPIClient.h"
#import "HRAppDelegate.h"
#import "HRPeoplePickerViewController_private.h"

#import "HRMPatient.h"

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
    if (URL && [[URL absoluteString] rangeOfString:location].location == 0) {
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    id<NSURLProtocolClient> client = [self client];
    
    // query string parameters
    NSString *queryString = [[[self request] URL] query];
    NSDictionary *queryParameters = [HRAPIClient parametersFromQueryString:queryString];
    NSString *action = [queryParameters objectForKey:@"key"];
    HRDebugLog(@"%@", queryParameters);
    
    // body parameters
    NSString *bodyString = [[NSString alloc] initWithData:[[self request] HTTPBody] encoding:NSUTF8StringEncoding];
    NSDictionary *bodyParameters = [HRAPIClient parametersFromQueryString:bodyString];
    HRDebugLog(@"%@", bodyParameters);
    
    // new medication
    if ([action isEqualToString:@"Levels"]) {
        HRDebugLog(@"%@", [bodyParameters objectForKey:@"pain"]);
        HRDebugLog(@"%@", [bodyParameters objectForKey:@"mood"]);
        HRDebugLog(@"%@", [bodyParameters objectForKey:@"energy"]);
        
        NSManagedObjectContext *context = [HRAppDelegate managedObjectContext];
        [context performBlockAndWait:^{
            HRMPatient *patient = [HRPeoplePickerViewController selectedPatient];
            patient.timelineLevels = bodyParameters;
            [context save:nil];
        }];
        
    }
    // NewMedication
    // MedRegiment
    // ConditionSymptoms 
    
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
