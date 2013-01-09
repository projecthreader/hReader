//
//  HRTimelineURLProtocol.m
//  HReader
//
//  Created by Caleb Davenport on 9/26/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRTimelineGETURLProtocol.h"
#import "HRPeoplePickerViewController_private.h"
#import "HRAppDelegate.h"
#import "HRAPIClient.h"

#import "HRMPatient.h"

@implementation HRTimelineGETURLProtocol

+ (void)load {
    @autoreleasepool {
        [NSURLProtocol registerClass:self];
    }
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if (![[request HTTPMethod] isEqualToString:@"GET"]) {
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
    
    // load calendar
    static NSCalendar *calendar = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    });
    
    // determine scope
    NSDate *startDate = [NSDate date];
    NSDate *endDate = startDate;
    NSURL *URL = [[self request] URL];
    NSDictionary *parameters = [HRAPIClient parametersFromQueryString:[URL query]];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSString *page = [parameters objectForKey:@"page"];
    if ([page isEqualToString:@"day"]) { [components setDay:-1]; }
    else if ([page isEqualToString:@"week"]) { [components setDay:-7]; }
    else if ([page isEqualToString:@"month"]) { [components setMonth:-1]; }
    else if ([page isEqualToString:@"year"]) { [components setYear:-1]; }
    else if ([page isEqualToString:@"decade"]) { [components setYear:-10]; }
    else { components = nil; }
    if (components) {
        startDate = [calendar dateByAddingComponents:components toDate:endDate options:0];
    }
    
    // get data
    __block NSData *data = nil;
    __block NSError *error = nil;
    [[HRAppDelegate managedObjectContext] performBlockAndWait:^{
        HRMPatient *patient = [HRPeoplePickerViewController selectedPatient];
        data = [patient timelineJSONPayloadWithStartDate:startDate endDate:endDate error:&error];
    }];
    
    // send response
    id<NSURLProtocolClient> client = [self client];
    if ([data length]) {
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc]
                                       initWithURL:[[self request] URL]
                                       statusCode:200
                                       HTTPVersion:@"HTTP/1.1"
                                       headerFields:@{
                                           @"Content-Length" : [NSString stringWithFormat:@"%lu", (unsigned long)[data length]],
                                           @"Content-Type" : @"application/json"
                                       }];
        [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [client URLProtocol:self didLoadData:data];
        [client URLProtocolDidFinishLoading:self];
    }
    else {
        [client URLProtocol:self didFailWithError:error];
    }
    
}

- (void)stopLoading {
    
}

@end
