//
//  HRTimelineURLProtocol.m
//  HReader
//
//  Created by Caleb Davenport on 9/26/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRTimelineURLProtocol.h"
#import "HRPeoplePickerViewController_private.h"
#import "HRMPatient.h"
#import "HRAppDelegate.h"
#import "HRAPIClient.h"

@implementation HRTimelineURLProtocol

+ (void)load {
    @autoreleasepool {
        [NSURLProtocol registerClass:self];
    }
}

+ (NSString *)timelineJSONPath {
    static NSString *path = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        path = [[NSBundle mainBundle] bundlePath];
        path = [path stringByAppendingPathComponent:@"timeline-angular/app/timeline.json"];
    });
    return path;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSURL *URL = [request URL];
    if ([URL isFileURL] && [[URL path] isEqualToString:[self timelineJSONPath]]) {
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    [[HRAppDelegate managedObjectContext] performBlock:^{
        NSURL *URL = [[self request] URL];
        HRMPatient *patient = [HRPeoplePickerViewController selectedPatient];
        
        // load calendar
        static NSCalendar *calendar = nil;
        static dispatch_once_t token;
        dispatch_once(&token, ^{
            calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        });
        
        // determine scope
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
        
        // load data
        id<NSURLProtocolClient> client = [self client];
        NSError *error = nil;
        NSData *data = [patient timelineJSONPayloadWithPredicate:predicate error:&error];
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
        
    }];
}

- (void)stopLoading {
    
}

@end
