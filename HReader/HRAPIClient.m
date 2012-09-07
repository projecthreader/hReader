//
//  HRAPIClient.m
//  HReader
//
//  Created by Caleb Davenport on 5/30/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRAPIClient_private.h"
#import "HRCryptoManager.h"
#import "HRRHExLoginViewController.h"

#import "DDXML.h"

#import "SSKeychain.h"

// oauth client resources
static NSString * const HROAuthClientIdentifier = @"c367aa7b8c87ce239981140511a7d158";
static NSString * const HROAuthClientSecret = @"bc121c529fcd1689704a24460b91f98b";
static NSString * const HROAuthKeychainService = @"org.hreader.oauth.2";
static NSMutableDictionary *allClients = nil;

//
static NSLock *HRAPIClientThreadLock;
static NSConditionLock *HRAPIClientWaitLock;

@interface NSString (HRAPIClientAdditions)

/*
 
 
 
 */
- (NSString *)hr_percentEncodedString;

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

@interface HRAPIClient () {
    NSString *_host;
    NSString *_accessToken;
    NSDate *_accessTokenExiprationDate;
    NSArray *_patientFeed;
}

/*
 
 Create an API client centered around the given host.
 
 */
- (id)initWithHost:(NSString *)host;

/*
 
 Fetch a URL request configured to perform a GET for the provided path.
 
 */
- (NSMutableURLRequest *)GETRequestWithPath:(NSString *)path;

/*
 
 Build a form-encoded query string with the given parameters.
 
 */
+ (NSString *)queryStringWithParameters:(NSDictionary *)parameters;

@end

@implementation HRAPIClient

#pragma mark - class methods

+ (void)initialize {
    if (self == [HRAPIClient class]) {
        HRAPIClientThreadLock = [[NSLock alloc] init];
        HRAPIClientWaitLock = [[NSConditionLock alloc] initWithCondition:0];
    }
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
    return [[SSKeychain accountsForService:HROAuthKeychainService] valueForKey:(__bridge NSString *)kSecAttrAccount];
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
        NSString *key = [obj substringToIndex:location];
        NSString *value = [obj substringFromIndex:(location + 1)];
        [dictionary setObject:value forKey:key];
    }];
    return dictionary;
}

#pragma mark - object methods

- (id)initWithHost:(NSString *)host {
    self = [super init];
    if (self) {
        _host = [host copy];
        NSString *name = [NSString stringWithFormat:@"org.mitre.hreader.oauth-request-queue.%@", _host];
        _requestQueue = dispatch_queue_create([name UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)destroy {
    [SSKeychain deletePasswordForService:HROAuthKeychainService account:_host];
    [allClients removeObjectForKey:_host];
}

- (void)patientFeed:(void (^)(NSArray *))completion ignoreCache:(BOOL)ignore {
    dispatch_async(_requestQueue, ^{
        NSArray *feed = _patientFeed;
        
        // check time stamp
        NSTimeInterval interval = ABS([_patientFeedLastFetchDate timeIntervalSinceNow]);
        if (interval > 60 * 5 || _patientFeedLastFetchDate == nil || ignore) {
            
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
                [IDs enumerateObjectsUsingBlock:^(NSString *patientID, NSUInteger index, BOOL *stop) {
                    NSDictionary *dict = 
                    [NSDictionary dictionaryWithObjectsAndKeys:
                     patientID, @"id", 
                     [names objectAtIndex:index], @"name",
                     nil];
                    [patients addObject:dict];
                }];
                _patientFeed = feed = [patients copy];
                _patientFeedLastFetchDate = [NSDate date];
            }
            else { feed = nil; }
            
        }
        
        // call completion handler
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(feed);
            });
        }
        
    });
}

- (void)patientFeed:(void (^) (NSArray *patients))completion {
    [self patientFeed:completion ignoreCache:NO];
}

- (NSMutableURLRequest *)GETRequestWithPath:(NSString *)path {

    // log initial statement
    NSLog(@"[%@] Building request", self);
    
    // make sure we have a refresh token
    NSString *refresh = [self refreshToken];
    if (refresh == nil) {
        NSLog(@"[%@] No refresh token is present", self);
        return nil;
    }
    
    // used to refresh the access token
    NSTimeInterval interval = [_accessTokenExiprationDate timeIntervalSinceNow];
    if (_accessTokenExiprationDate) { NSLog(@"[%@] Access token expires in %f minutes", self, interval / 60.0); }
    NSDictionary *refreshParameters = @{
        @"refresh_token" : refresh,
        @"grant_type" : @"refresh_token"
    };
    
    // make sure we have both required elements
    if (_accessToken == nil || _accessTokenExiprationDate == nil || interval < 60.0) {
        NSLog(@"[%@] Access token is invalid -- refreshing...", self);
        if (![self refreshAccessTokenWithParameters:refreshParameters]) {
            return nil;
        }
    }
    
    // check if our access token will expire soon
    else if (interval < 60.0 * 3.0) {
        NSLog(@"[%@] Access token will expire soon -- refreshing", self);
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
    if (connectionError) { NSLog(@"[API] %@", connectionError); }
    if (body) {
        NSError *JSONError = nil;
        payload = [NSJSONSerialization JSONObjectWithData:body options:0 error:&JSONError];
        if (JSONError) { NSLog(@"[API] %@", JSONError); }
    }
    
    // parse payload
    if ([payload objectForKey:@"expires_in"] && [payload objectForKey:@"access_token"]) {
        if ([payload objectForKey:@"refresh_token"]) {
            HRCryptoManagerSetKeychainItemString(HROAuthKeychainService, _host, [payload objectForKey:@"refresh_token"]);
        }
        NSTimeInterval interval = [[payload objectForKey:@"expires_in"] doubleValue];
        _accessTokenExiprationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
        _accessToken = [payload objectForKey:@"access_token"];
        return YES;
    }
    
    // unauthorized
    else if ([[payload objectForKey:@"error"] isEqualToString:@"invalid_grant"]) {
        [HRAPIClientThreadLock lock];
        dispatch_async(dispatch_get_main_queue(), ^{
            HRRHExLoginViewController *controller = [HRRHExLoginViewController loginViewControllerForClient:self];
            controller.target = self;
            controller.action = @selector(loginControllerDidAuthenticate:);
            [controller setQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
            UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
            id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
            [[[delegate window] rootViewController] presentViewController:navigation animated:YES completion:nil];
        });
        [HRAPIClientWaitLock lockWhenCondition:1];
        [HRAPIClientWaitLock unlockWithCondition:0];
        [HRAPIClientThreadLock unlock];
        return YES;
        
    }
    
    // payload error
    else {
        NSLog(@"[API] Error Payload: %@", payload);
    }
    
    // last ditch return
    return NO;
    
}

- (NSString *)refreshToken {
    return HRCryptoManagerKeychainItemString(HROAuthKeychainService, _host);
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

- (void)JSONForPatientWithIdentifier:(NSString *)identifier startBlock:(void (^) (void))startBlock finishBlock:(void (^) (NSDictionary *payload))finishBlock {
    dispatch_async(_requestQueue, ^{
        
        // start block
        if (startBlock) { dispatch_async(dispatch_get_main_queue(), startBlock); }
        
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
        NSDictionary *dictionary = nil;
        if (data && [response statusCode] == 200) {
            dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
        }
        
        // return
        if (finishBlock) { dispatch_async(dispatch_get_main_queue(), ^{ finishBlock(dictionary); }); }
        
    });
}

- (void)JSONForPatientWithIdentifier:(NSString *)identifier finishBlock:(void (^) (NSDictionary *payload))block {
    [self JSONForPatientWithIdentifier:identifier startBlock:nil finishBlock:block];
}

#pragma mark - login callback

- (void)loginControllerDidAuthenticate:(HRRHExLoginViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:^{
        [HRAPIClientWaitLock lock];
        [HRAPIClientWaitLock unlockWithCondition:1];
    }];
}

@end
