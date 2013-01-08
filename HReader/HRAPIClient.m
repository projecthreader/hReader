//
//  HRAPIClient.m
//  HReader
//
//  Created by Caleb Davenport on 5/30/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <SecureFoundation/SecureFoundation.h>

#import "HRAPIClient_private.h"
#import "HRCryptoManager.h"
#import "HRRHExLoginViewController.h"

#import "DDXML.h"

#define hr_dispatch_main(block) dispatch_async(dispatch_get_main_queue(), block)

// oauth client resources
static NSString * const HROAuthClientIdentifier = @"c367aa7b8c87ce239981140511a7d158";
static NSString * const HROAuthClientSecret = @"bc121c529fcd1689704a24460b91f98b";
static NSString * const HROAuthKeychainService = @"org.hreader.oauth.2";
static NSMutableDictionary *allClients = nil;

@interface NSString (HRAPIClientAdditions)
- (NSString *)hr_percentEncodedString;
@end

@interface HRAPIClient () {
    NSString *_host;
    NSString *_accessToken;
    NSDate *_accessTokenExpirationDate;
    NSArray *_patientFeed;
    NSConditionLock *_authorizationLock;
    dispatch_queue_t _requestQueue;
}

@end

@implementation HRAPIClient

#pragma mark - class methods

+ (NSLock *)authorizationLock {
    static NSLock *lock = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        lock = [[NSLock alloc] init];
    });
    return lock;
}

+ (HRAPIClient *)clientWithHost:(NSString *)host {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        allClients = [[NSMutableDictionary alloc] initWithCapacity:1];
    });
    HRAPIClient *client = [allClients objectForKey:host];
    if (client == nil) {
        client = [[HRAPIClient alloc] initWithHost:host];
        [allClients setObject:client forKey:host];
    }
    return client;
}

+ (NSArray *)hosts {
    return [[IMSKeychain accountsForService:HROAuthKeychainService] valueForKey:(__bridge NSString *)kSecAttrAccount];
}

+ (NSString *)queryStringWithParameters:(NSDictionary *)parameters {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[parameters count]];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [array addObject:[NSString stringWithFormat:@"%@=%@", [key hr_percentEncodedString], [obj hr_percentEncodedString]]];
    }];
    return [array componentsJoinedByString:@"&"];
}

+ (NSDictionary *)parametersFromQueryString:(NSString *)string {
    NSArray *array = [string componentsSeparatedByString:@"&"];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[array count]];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSUInteger location = [obj rangeOfString:@"="].location;
        if (location != NSNotFound) {
            NSString *key = [obj substringToIndex:location];
            NSString *value = [obj substringFromIndex:(location + 1)];
            [dictionary setObject:value forKey:key];
        }
    }];
    return dictionary;
}

#pragma mark - retrieve data from the api

- (void)patientFeed:(void (^)(NSArray *patients))completion ignoreCache:(BOOL)ignore {
    dispatch_async(_requestQueue, ^{
        hr_dispatch_main(^{
            [[UIApplication sharedApplication] hr_pushNetworkOperation];
        });
        NSArray *feed = _patientFeed;
        
        // check time stamp
        NSTimeInterval interval = ABS([_patientFeedLastFetchDate timeIntervalSinceNow]);
        if (interval > 50 * 5 || _patientFeedLastFetchDate == nil || ignore) {
            
            // get the request
            NSMutableURLRequest *request = [self GETRequestWithPath:@"/"];
            
            // run request
            NSError *error = nil;
            NSHTTPURLResponse *response = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            // get ids
            DDXMLDocument *document = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
            [[document rootElement] addNamespace:[DDXMLNode namespaceWithName:@"atom" stringValue:@"http://www.w3.org/2005/Atom"]];
            NSArray *IDs = [[document nodesForXPath:@"/atom:feed/atom:entry/atom:id" error:nil] valueForKey:@"stringValue"];
            NSArray *names = [[document nodesForXPath:@"/atom:feed/atom:entry/atom:title" error:nil] valueForKey:@"stringValue"];
            
            // build array
            if ([response statusCode] == 200 && IDs && [IDs count] == [names count]) {
                NSMutableArray *patients = [[NSMutableArray alloc] initWithCapacity:[IDs count]];
                [IDs enumerateObjectsUsingBlock:^(NSString *patientID, NSUInteger idx, BOOL *stop) {
                    NSDictionary *dict = @{
                        @"id" : patientID,
                        @"name" : [names objectAtIndex:idx]
                    };
                    [patients addObject:dict];
                }];
                _patientFeed = feed = [patients copy];
                _patientFeedLastFetchDate = [NSDate date];
            }
            else { feed = nil; }
            
        }
        
        // call completion handler
        hr_dispatch_main(^{
            [[UIApplication sharedApplication] hr_popNetworkOperation];
            if (completion) { completion(feed); }
        });
        
    });
}

- (void)patientFeed:(void (^) (NSArray *patients))completion {
    [self patientFeed:completion ignoreCache:NO];
}

- (NSDictionary *)JSONForPatientWithIdentifier:(NSString *)identifier {
    __block NSDictionary *dictionary = nil;
    dispatch_sync(_requestQueue, ^{
        
        // start block
        hr_dispatch_main(^{
            [[UIApplication sharedApplication] hr_pushNetworkOperation];
        });
        
        // create request
        NSString *path = [NSString stringWithFormat:@"/records/%@/c32/%@", identifier, identifier];
        NSMutableURLRequest *request = [self GETRequestWithPath:path];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        // run request
        NSError *connectionError = nil;
        NSHTTPURLResponse *response = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
        
        // create patient
        NSError *JSONError = nil;
        if (data && [response statusCode] == 200) {
            dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
        }
        
        // finish block
        hr_dispatch_main(^{
            [[UIApplication sharedApplication] hr_popNetworkOperation];
        });
        
    });
    return dictionary;
}

- (void)JSONForPatientWithIdentifier:(NSString *)identifier startBlock:(void (^) (void))startBlock finishBlock:(void (^) (NSDictionary *payload))finishBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // start block
        hr_dispatch_main(^{
            if (startBlock) { startBlock(); }
        });
        
        // run request
        NSDictionary *dictionary = [self JSONForPatientWithIdentifier:identifier];
        
        // finish block
        hr_dispatch_main(^{
            if (finishBlock) { finishBlock(dictionary); }
        });
        
    });
}

#pragma mark - send data

- (BOOL) sendDataWithParameters:(NSDictionary *)params forPatientWithIdentifier:(NSString *)identifier{
    BOOL success = NO;
    // start block
    hr_dispatch_main(^{
        [[UIApplication sharedApplication] hr_pushNetworkOperation];
    });
    
    // create request
    NSString *path = [NSString stringWithFormat:@"/records/%@/c32/%@", identifier, identifier];
    NSMutableURLRequest *request = [self POSTRequestWithPath:path andParameters:params];
    
    // run request
    NSError *connectionError = nil;
    NSHTTPURLResponse *response = nil;
    //TODO: LMD discard data?
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    success = ([response statusCode] == 200);
    
    // finish block
    if(success){
        hr_dispatch_main(^{
            [[UIApplication sharedApplication] hr_popNetworkOperation];
        });
    }
    
    
    return success;
}

#pragma mark - build requests

- (NSMutableURLRequest *)GETRequestWithPath:(NSString *)path {
    
    // log initial statement
    HRDebugLog(@"Building request");
    
    // make sure we have a refresh token
    NSString *refresh = HRCryptoManagerKeychainItemString(HROAuthKeychainService, _host);
    if (refresh == nil) {
        HRDebugLog(@"No refresh token is present");
        return nil;
    }
    
    // used to refresh the access token
    NSTimeInterval interval = [_accessTokenExpirationDate timeIntervalSinceNow];
    if (_accessTokenExpirationDate) { HRDebugLog(@"Access token expires in %f minutes", interval / 60.0); }
    NSDictionary *refreshParameters = @{
        @"refresh_token" : refresh,
        @"grant_type" : @"refresh_token"
    };
    
    // make sure we have both required elements
    if (_accessToken == nil || _accessTokenExpirationDate == nil || interval < 60.0) {
        HRDebugLog(@"Access token is invalid -- refreshing...");
        if (![self refreshAccessTokenWithParameters:refreshParameters]) {
            return nil;
        }
    }
    
    // check if our access token will expire soon
    else if (interval < 60.0 * 3.0) {
        HRDebugLog(@"Access token will expire soon -- refreshing later");
        dispatch_async(_requestQueue, ^{
            [self refreshAccessTokenWithParameters:refreshParameters];
        });
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
    return request;
    
}

- (NSMutableURLRequest *)POSTRequestWithPath:(NSString *)path andParameters:(NSDictionary *)params {
    
    // log initial statement
    HRDebugLog(@"Building request");
    
    // make sure we have a refresh token
    NSString *refresh = HRCryptoManagerKeychainItemString(HROAuthKeychainService, _host);
    if (refresh == nil) {
        HRDebugLog(@"No refresh token is present");
        return nil;
    }
    
    // used to refresh the access token
    NSTimeInterval interval = [_accessTokenExpirationDate timeIntervalSinceNow];
    if (_accessTokenExpirationDate) { HRDebugLog(@"Access token expires in %f minutes", interval / 60.0); }
    NSDictionary *refreshParameters = @{
    @"refresh_token" : refresh,
    @"grant_type" : @"refresh_token"
    };
    
    // make sure we have both required elements
    if (_accessToken == nil || _accessTokenExpirationDate == nil || interval < 60.0) {
        HRDebugLog(@"Access token is invalid -- refreshing...");
        if (![self refreshAccessTokenWithParameters:refreshParameters]) {
            return nil;
        }
    }
    
    // check if our access token will expire soon
    else if (interval < 60.0 * 3.0) {
        HRDebugLog(@"Access token will expire soon -- refreshing later");
        dispatch_async(_requestQueue, ^{
            [self refreshAccessTokenWithParameters:refreshParameters];
        });
    }
    
    // build request parameters
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [parameters setObject:_accessToken forKey:@"access_token"];
    
    NSString *query = [HRAPIClient queryStringWithParameters:parameters];
    NSData *post = [query dataUsingEncoding:NSUnicodeStringEncoding allowLossyConversion:YES];//LMD TODO: Change to ascii?
    NSString *URLString = [NSString stringWithFormat:@"https://%@%@", _host, path];//TODO: LMD other post URL changes?
    NSURL *URL = [NSURL URLWithString:URLString];
    
    // build request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d", [post length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:post];
    
    
    
    
    // return
    return request;
    
}

- (NSURLRequest *)authorizationRequest {
    NSDictionary *parameters = @{
        @"client_id" : HROAuthClientIdentifier,
        @"response_type" : @"code"
    };
    NSString *query = [HRAPIClient queryStringWithParameters:parameters];
    NSString *URLString = [NSString stringWithFormat:@"https://%@/oauth2/authorize?%@", _host, query];
    NSURL *URL = [NSURL URLWithString:URLString];
    return [[NSURLRequest alloc] initWithURL:URL];
}

#pragma mark - object methods

- (id)initWithHost:(NSString *)host {
    self = [super init];
    if (self) {
        _host = [host copy];
        NSString *name = [NSString stringWithFormat:@"org.mitre.hreader.rhex-queue.%@", _host];
        _requestQueue = dispatch_queue_create([name UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)destroy {
    [IMSKeychain deletePasswordForService:HROAuthKeychainService account:_host];
    [allClients removeObjectForKey:_host];
}

- (BOOL)refreshAccessTokenWithParameters:(NSDictionary *)parameters {
    
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
    if (connectionError) { HRDebugLog(@"%@", connectionError); }
    if (body) {
        NSError *JSONError = nil;
        payload = [NSJSONSerialization JSONObjectWithData:body options:0 error:&JSONError];
        if (JSONError) { HRDebugLog(@"%@", JSONError); }
    }
    
    // parse payload
    if ([payload objectForKey:@"expires_in"] && [payload objectForKey:@"access_token"]) {
        if ([payload objectForKey:@"refresh_token"]) {
            HRCryptoManagerSetKeychainItemString(HROAuthKeychainService, _host, [payload objectForKey:@"refresh_token"]);
        }
        NSTimeInterval interval = [[payload objectForKey:@"expires_in"] doubleValue];
        _accessTokenExpirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
        _accessToken = [payload objectForKey:@"access_token"];
        return YES;
    }
    
    // unauthorized
    else if ([[payload objectForKey:@"error"] isEqualToString:@"invalid_grant"]) {
        [[HRAPIClient authorizationLock] lock];
        dispatch_async(dispatch_get_main_queue(), ^{
            HRRHExLoginViewController *controller = [HRRHExLoginViewController loginViewControllerForClient:self];
            controller.target = self;
            controller.action = @selector(loginControllerDidAuthenticate:);
            UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
            id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
            [[[delegate window] rootViewController] presentViewController:navigation animated:YES completion:nil];
        });
        _authorizationLock = [[NSConditionLock alloc] initWithCondition:0];
        [_authorizationLock lockWhenCondition:1];
        [_authorizationLock unlock];
        _authorizationLock = nil;
        [[HRAPIClient authorizationLock] unlock];
        return YES;
        
    }
    
    // payload error
    else {
        HRDebugLog(@"%@", payload);
    }
    
    // last ditch return
    return NO;
    
}

#pragma mark - login callback

- (void)loginControllerDidAuthenticate:(HRRHExLoginViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:^{
        [_authorizationLock lock];
        [_authorizationLock unlockWithCondition:1];
    }];
}

@end

@implementation NSString (HRAPIClientAdditions)

- (NSString *)hr_percentEncodedString {
    CFStringRef string = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                 (__bridge CFStringRef)self,
                                                                 NULL,
                                                                 CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                 kCFStringEncodingUTF8);
    return (__bridge_transfer NSString *)string;
}

@end
