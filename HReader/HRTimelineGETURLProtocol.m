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
    NSURL *URL = [[self request] URL];
    NSDate *date = [NSDate date];
    NSDictionary *parameters = [HRAPIClient parametersFromQueryString:[URL query]];
    NSPredicate *predicate = nil;
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSString *page = [parameters objectForKey:@"page"];
    if ([page isEqualToString:@"day"]) { [components setDay:-1]; }
    else if ([page isEqualToString:@"week"]) { [components setWeek:-1]; }
    else if ([page isEqualToString:@"month"]) { [components setMonth:-1]; }
    else if ([page isEqualToString:@"year"]) { [components setYear:-1]; }
    else if ([page isEqualToString:@"decade"]) { [components setYear:-10]; }
    else { components = nil; }
    if (components) {
        date = [calendar dateByAddingComponents:components toDate:date options:0];
        predicate = [NSPredicate predicateWithFormat:@"date >= %@", date];
    }
    
    // get data
    __block NSData *data = nil;
    __block NSError *error = nil;
    [[HRAppDelegate managedObjectContext] performBlockAndWait:^{
        HRMPatient *patient = [HRPeoplePickerViewController selectedPatient];
        data = [patient timelineJSONPayloadWithPredicate:predicate error:&error];
    }];
    
    // send response
    id<NSURLProtocolClient> client = [self client];
    if ([data length]) {
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc]
                                       initWithURL:[[self request] URL]
                                       MIMEType:@"application/json"
                                       expectedContentLength:[data length]
                                       textEncodingName:nil];
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
