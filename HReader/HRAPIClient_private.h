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
 
 Request the patient feed from the receiver. This method returns imediatly and
 notifies the caller upon completion using the completion block.
 
 The completion accepts an array of dictionaries each having two keys: id and
 name. Should an error occur, `patients` will be nil. It will be executed on
 the main queue.
 
 The `ignoreCache` parameter allows the caller to bust the local cache in favor
 of data from the server. This method does NOT invalidate the local cache, it
 simply ignores it.
 
 */
- (void)patientFeed:(void (^) (NSArray *patients))completion ignoreCache:(BOOL)ignore;

/*
 
 Force the client to logout and destroy all keychain items.
 
 */
- (void)destroy;

@end
