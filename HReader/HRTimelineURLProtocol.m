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
        path = [path stringByAppendingPathComponent:@"timeline-angular/app/records/timeline.json"];
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
    NSManagedObjectContext *context = [HRAppDelegate managedObjectContext];
    [context performBlock:^{
        HRMPatient *patient = [HRPeoplePickerViewController selectedPatientInContext:context];
        NSError *error = nil;
        NSData *data = [patient timelineJSONPayload:&error];
//        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if ([data length]) {
            NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc]
                                           initWithURL:[[self request] URL]
                                           MIMEType:@"text/json"
                                           expectedContentLength:[data length]
                                           textEncodingName:nil];
            [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            [[self client] URLProtocol:self didLoadData:data];
            [[self client] URLProtocolDidFinishLoading:self];
        }
        else {
            [[self client] URLProtocol:self didFailWithError:error];
        }
    }];
}

- (void)stopLoading {
    
}

@end
