//
//  HRAPIClient.m
//  HReader
//
//  Created by Caleb Davenport on 5/30/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRAPIClient_private.h"

#import "SSKeychain.h"
#import "DDXML.h"

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
    NSString *_host;
    NSString *_accessToken;
    NSDate *_accessTokenExiprationDate;
    NSArray *_patientFeed;
}

/*
 
 
 
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

+ (NSArray *)accounts {
    return [[SSKeychain accountsForService:HROAuthKeychainService] valueForKey:(__bridge NSString *)kSecAttrAccount];
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

- (void)patientFeed:(void (^)(NSArray *))completion honorCache:(BOOL)cache {
    
    // check time stamp
    NSTimeInterval interval = ABS([_patientFeedLastFetchDate timeIntervalSinceNow]);
    if (interval > 60 * 5 || _patientFeedLastFetchDate == nil || !cache) {
        
        // refetch
        dispatch_queue_t queue = dispatch_get_current_queue();
        dispatch_async(_requestQueue, ^{
            NSMutableURLRequest *request = [self GETRequestWithPath:@"/"];
            NSMutableArray *patients = nil;
            if (request) {
                
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
                if ([IDs count] == [names count]) {
                    patients = [[NSMutableArray alloc] initWithCapacity:[IDs count]];
                    [IDs enumerateObjectsUsingBlock:^(NSString *patientID, NSUInteger index, BOOL *stop) {
                        NSDictionary *dict = 
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         patientID, @"id", 
                         [names objectAtIndex:index], @"name",
                         nil];
                        [patients addObject:dict];
                    }];
                    _patientFeed = [patients copy];
                    _patientFeedLastFetchDate = [NSDate date];
                }
            }
            
            // call completion handler
            dispatch_async(queue, ^{
                completion(_patientFeed);
            });
            
        });
    }
    
    // we already have something
    else {
        completion(_patientFeed);
    }
    
}

- (void)patientFeed:(void (^) (NSArray *patients))completion {
    [self patientFeed:completion honorCache:YES];
}

- (NSMutableURLRequest *)GETRequestWithPath:(NSString *)path {

    // log initial statement
    NSLog(@"[%@] Building request", self);
    
    // make sure we have a refresh token
    NSString *refresh = [self refreshToken];
    if (!refresh) {
        NSLog(@"[%@] No refresh token is present", self);
        return nil;
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
    if (connectionError) { NSLog(@"%@", connectionError); }
    if (body) {
        NSError *JSONError = nil;
        payload = [NSJSONSerialization JSONObjectWithData:body options:0 error:&JSONError];
        if (JSONError) { NSLog(@"%@", connectionError); }
    }
    
    // parse payload
    if ([payload objectForKey:@"refresh_token"] && [payload objectForKey:@"expires_in"] && [payload objectForKey:@"access_token"]) {
        [SSKeychain setPassword:[payload objectForKey:@"refresh_token"] forService:HROAuthKeychainService account:_host];
        NSTimeInterval interval = [[payload objectForKey:@"expires_in"] doubleValue];
        _accessTokenExiprationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
        _accessToken = [payload objectForKey:@"access_token"];
        return YES;
    }
    
    // last ditch return
    return NO;
    
}

- (NSString *)refreshToken {
    return [SSKeychain passwordForService:HROAuthKeychainService account:_host];
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

- (void)JSONForPatientWithIdentifier:(NSString *)identifier completion:(void (^) (NSDictionary *payload))block {
    dispatch_queue_t queue = dispatch_get_current_queue();
    dispatch_async(_requestQueue, ^{
        
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
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
        
        // return
        dispatch_async(queue, ^{
            block(dictionary);
        });
        
    });
}

@end
