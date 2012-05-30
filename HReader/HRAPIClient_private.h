//
//  HRAPIClient_private.h
//  HReader
//
//  Created by Caleb Davenport on 5/30/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRAPIClient.h"

@interface HRAPIClient () {
@public
    dispatch_queue_t _requestQueue;
    NSDate *_patientFeedLastFetchDate;
}

/*
 
 Build the authorization request that is presented to the user through a web
 view.
 
 */
- (NSURLRequest *)authorizationRequest;

/*
 
 Get the access token payload given the appropriate parameters. This method
 will not execute anything if another request is in 
 
 The parameters dictionary MUST contain the "grant_type" which should be either 
 "authorization_code" or "refresh_token", and the appropriate associated value.
 
 It is up to the caller to validate the returned payload and store any values.
 
 */
- (BOOL)refreshAccessTokenWithParameters:(NSDictionary *)parameters;

/*
 
 
 
 */
- (void)patientFeed:(void (^)(NSArray *))completion honorCache:(BOOL)cache;

/*
 
 Decode the given query string into a set of parameters.
 
 */
+ (NSDictionary *)parametersFromQueryString:(NSString *)string;

@end
