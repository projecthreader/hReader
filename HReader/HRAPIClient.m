//
//  HRAPIClient.m
//  HReader
//
//  Created by Caleb Davenport on 5/30/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRAPIClient.h"

#import "SSKeychain.h"

// oauth client resources
static NSString * const HROAuthClientIdentifier = @"c367aa7b8c87ce239981140511a7d158";
static NSString * const HROAuthClientSecret = @"bc121c529fcd1689704a24460b91f98b";
static NSString * const HROAuthKeychainService = @"org.mitre.hreader.refresh-token";

@interface NSString (HROAuthControllerAdditions)

/*
 
 
 
 */
- (NSString *)percentEncodedString;

@end

@implementation NSString (HROAuthControllerAdditions)

- (NSString *)percentEncodedString {
    CFStringRef string = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                 (__bridge CFStringRef)self,
                                                                 NULL,
                                                                 CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                 kCFStringEncodingUTF8);
    return (__bridge_transfer NSString *)string;
}

@end

@interface HRAPIClient () {
@private
    dispatch_queue_t _requestQueue;
    NSString *_host;
    NSString *_accessToken;
    NSDate *_accessTokenExiprationDate;
}

/*
 
 
 
 */
- (id)initWithHost:(NSString *)host;

/*
 
 Refresh the stored refresh token, access token, and access token expiration
 date from the given payload.
 
 */
- (BOOL)refreshAccessTokenWithPayload:(NSDictionary *)payload;

/*
 
 Get the access token payload given the appropriate parameters. This method
 will not execute anything if another request is in 
 
 The parameters dictionary MUST contain the "grant_type" which should be either 
 "authorization_code" or "refresh_token", and the appropriate associated value.
 
 It is up to the caller to validate the returned payload and store any values.
 
 */
- (NSDictionary *)accessTokenWithParameters:(NSDictionary *)parameters;

/*
 
 Build the authorization request that is presented to the user through a web
 view.
 
 */
- (NSURLRequest *)authorizationRequest;

/*
 
 Build a GET request given the path, a completion block, and the queue on which
 to call the completion block.
 
 */
- (void)GETRequestWithPath:(NSString *)path queue:(dispatch_queue_t)queue completion:(void (^) (NSMutableURLRequest *request))block;

/*
 
 Build a form-encoded query string with the given parameters.
 
 */
+ (NSString *)queryStringWithParameters:(NSDictionary *)parameters;

/*
 
 Decode the given query string into a set of parameters.
 
 */
+ (NSDictionary *)parametersFromQueryString:(NSString *)string;

@end

@implementation HRAPIClient

#pragma mark - get a client

+ (HRAPIClient *)clientWithHost:(NSString *)host {
    static NSMutableDictionary *dictionary = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        dictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
    });
    HRAPIClient *client = [dictionary objectForKey:host];
    if (client == nil) {
        client = [[HRAPIClient alloc] initWithHost:host];
        [dictionary setObject:client forKey:host];
    }
    return client;
}

#pragma mark - build a client

- (id)initWithHost:(NSString *)host {
    self = [super init];
    if (self) {
        _host = [host copy];
        NSString *name = [NSString stringWithFormat:@"org.mitre.hreader.oauth-request-queue.%@", _host];
        _requestQueue = dispatch_queue_create([name UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - oauth and api methods

- (void)GETRequestWithPath:(NSString *)path completion:(void (^) (NSMutableURLRequest *request))block {
    dispatch_queue_t queue = dispatch_get_current_queue();
    [self GETRequestWithPath:path queue:queue completion:block];
}

- (NSMutableURLRequest *)GETRequestWithPath:(NSString *)path {
    NSMutableURLRequest * __block toReturn = nil;
    NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:1];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self GETRequestWithPath:path completion:^(NSMutableURLRequest *request) {
            [lock lockWhenCondition:1];
            toReturn = request;
            [lock unlockWithCondition:0];
        }];
    });
    [lock lockWhenCondition:0];
    [lock unlock];
    return toReturn;
}

- (void)GETRequestWithPath:(NSString *)path queue:(dispatch_queue_t)queue completion:(void (^) (NSMutableURLRequest *request))block {
    dispatch_async(_requestQueue, ^{
        
        // log initial statement
        NSLog(@"[%@] Building request", self);
        
        // make sure we have a refresh token
        NSString *refresh = [self refreshToken];
        if (!refresh) {
            NSLog(@"[%@] No refresh token is present", self);
            dispatch_async(queue, ^{ block(nil); });
            return;
        }
        
        // used to refresh the access token
        NSTimeInterval interval = [_accessTokenExiprationDate timeIntervalSinceNow];
        if (_accessTokenExiprationDate) { NSLog(@"[%@] Access token expires in %f minutes", self, interval / 60.0); }
        NSDictionary *refreshParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                           refresh, @"refresh_token",
                                           @"refresh_token", @"grant_type",
                                           nil];
        
        // make sure we have both required elements
        if (!_accessToken || !_accessTokenExiprationDate || interval < 60.0) {
            NSLog(@"[%@] Access token is invalid -- refreshing...", self);
            NSDictionary *payload = [self accessTokenWithParameters:refreshParameters];
            if ([self refreshAccessTokenWithPayload:payload]) {
                [self GETRequestWithPath:path queue:queue completion:block];
            }
            else {
                dispatch_async(queue, ^{ block(nil); });
            }
            return;
        }
        
        // check if our access token will expire soon
        if (interval < 60.0 * 3.0) {
            NSLog(@"[%@] Access token will expire soon -- refreshing", self);
            NSDictionary *payload = [self accessTokenWithParameters:refreshParameters];
            [self refreshAccessTokenWithPayload:payload];
        }
        
        // build request parameters
        NSDictionary *parameters = [NSDictionary dictionaryWithObject:_accessToken forKey:@"access_token"];
        NSString *query = [HRAPIClient queryStringWithParameters:parameters];
        NSString *URLString = [NSString stringWithFormat:@"https://%@%@?%@", _host, path, query];
        NSURL *URL = [NSURL URLWithString:URLString];
        
        // build request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
        [request setHTTPShouldHandleCookies:NO];
        [request setHTTPMethod:@"GET"];
        
        // return
        dispatch_async(queue, ^{ block(request); });
        
    });
}

- (NSDictionary *)accessTokenWithParameters:(NSDictionary *)parameters {
    
    // build request parameters
    NSMutableDictionary *requestParameters = [parameters mutableCopy];
    [requestParameters setObject:HROAuthClientIdentifier forKey:@"client_id"];
    [requestParameters setObject:HROAuthClientSecret forKey:@"client_secret"];
    NSString *query = [HRAPIClient queryStringWithParameters:requestParameters];
    NSData *data = [query dataUsingEncoding:NSUTF8StringEncoding];
    NSString *length = [NSString stringWithFormat:@"%lu", (unsigned long)[data length]];
    
    // build request
    NSString *URLString = [NSString stringWithFormat:@"https://%@/oauth2/token", _host];
    NSURL *URL = [NSURL URLWithString:URLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:length forHTTPHeaderField:@"Content-Length"];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    
    // run request
    NSDictionary *payload = nil;
    NSError *connectionError = nil;
    NSHTTPURLResponse *response = nil;
    NSData *body = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    if (connectionError) { NSLog(@"%@", connectionError); }
    if (body) {
        NSError *JSONError = nil;
        payload = [NSJSONSerialization JSONObjectWithData:body options:0 error:&JSONError];
        if (JSONError) { NSLog(@"%@", connectionError); }
    }
    
    // return
    return payload;
    
}

- (BOOL)refreshAccessTokenWithPayload:(NSDictionary *)payload {
    if ([payload objectForKey:@"refresh_token"] && [payload objectForKey:@"expires_in"] && [payload objectForKey:@"access_token"]) {
//        [SSKeychain setPassword:[payload objectForKey:@"refresh_token"] forService:HROAuthKeychainService account:_host];
        [SSKeychain setPassword:[payload objectForKey:@"refresh_token"] forService:HROAuthKeychainService account:@"default"];
        NSTimeInterval interval = [[payload objectForKey:@"expires_in"] doubleValue];
        _accessTokenExiprationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
        _accessToken = [payload objectForKey:@"access_token"];
        return YES;
    }
    return NO;
}

- (NSString *)refreshToken {
//    return [SSKeychain passwordForService:HROAuthKeychainService account:_host];
    return [SSKeychain passwordForService:HROAuthKeychainService account:@"default"];
}

- (NSURLRequest *)authorizationRequest {
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                HROAuthClientIdentifier, @"client_id",
                                @"code", @"response_type",
                                nil];
    NSString *query = [HRAPIClient queryStringWithParameters:parameters];
    NSString *URLString = [NSString stringWithFormat:@"https://%@/oauth2/authorize?%@", _host, query];
    NSURL *URL = [NSURL URLWithString:URLString];
    return [[NSURLRequest alloc] initWithURL:URL];
}

+ (NSString *)queryStringWithParameters:(NSDictionary *)parameters {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[parameters count]];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [array addObject:[NSString stringWithFormat:@"%@=%@", [key percentEncodedString], [obj percentEncodedString]]];
    }];
    return [array componentsJoinedByString:@"&"];
}

+ (NSDictionary *)parametersFromQueryString:(NSString *)string {
    NSArray *array = [string componentsSeparatedByString:@"&"];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[array count]];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSUInteger location = [obj rangeOfString:@"="].location;
        NSString *key = [obj substringToIndex:location];
        NSString *value = [obj substringFromIndex:(location + 1)];
        [dictionary setObject:value forKey:key];
    }];
    return dictionary;
}

@end
