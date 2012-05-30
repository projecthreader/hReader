//
//  HRAPIClient.h
//  HReader
//
//  Created by Caleb Davenport on 5/30/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRAPIClient : NSObject

/*
 
 Set the host name (or IP address) of the RHEx server.
 
 */
+ (HRAPIClient *)clientWithHost:(NSString *)host;

/*
 
 
 
 */
+ (NSArray *)accounts;

/*
 
 Fetch a URL request configured to perform a GET for the provided path. The
 completion handler will be called with the request once one is available, or
 nil if none could be created. The completion handler will be called on the
 block that initiated the method call.
 
 */
- (void)GETRequestWithPath:(NSString *)path completion:(void (^) (NSMutableURLRequest *request))block;
- (NSMutableURLRequest *)GETRequestWithPath:(NSString *)path;

@end
