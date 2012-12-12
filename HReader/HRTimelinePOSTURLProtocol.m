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
#import "HRMTimelineLevel.h"

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
#define PRIVATE_CONTEXT 1
#if PRIVATE_CONTEXT
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [context setParentContext:[HRAppDelegate managedObjectContext]];
#else
    NSManagedObjectContext *context = [HRAppDelegate managedObjectContext];
#endif
    
    
    // query string parameters
    NSString *queryString = [[[self request] URL] query];
    NSDictionary *queryParameters = [HRAPIClient parametersFromQueryString:queryString];
    NSString *action = [queryParameters objectForKey:@"key"];
    HRDebugLog(@"Query parameters: %@", queryParameters);
    
    // body parameters
    NSString *bodyString = [[NSString alloc] initWithData:[[self request] HTTPBody] encoding:NSUTF8StringEncoding];
    NSDictionary *bodyParameters = [HRAPIClient parametersFromQueryString:bodyString];
    HRDebugLog(@"Body parameters: %@", bodyParameters);
    
    [context performBlockAndWait:^{
        HRMPatient *patient = [HRPeoplePickerViewController selectedPatientInContext:context];
        
        // levels
        if ([action isEqualToString:@"Levels"]) {
            HRMTimelineLevel *level = [HRMTimelineLevel instanceInContext:context];
            level.patient = patient;
            level.data = bodyParameters;
        }
        
        // new medication
        else if ([action isEqualToString:@"NewMedication"]) {
//            special: select-choice-add
//            dosage: select-choice-by
//            frequency: select-choice-freq
        }
        
        // new med regiment
        else if ([action isEqualToString:@"MedRegiment"]) {
            
        }
        
        // save
        NSError *error = nil;
        if (![context save:&error]) { HRDebugLog(@"Failed to save levels: %@", error); }
        NSLog(@"Passed the save.");
        
    }];
    
    // send redirect
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[HRTimelinePOSTURLProtocol indexURL]];
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
