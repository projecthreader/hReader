//
//  HROAuthController.m
//  HReader
//
//  Created by Caleb Davenport on 5/23/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HROAuthController.h"

#import "GCOAuth.h"

#import "SSKeychain.h"

#if !__has_feature(objc_arc)
#error This class requires ARC.
#endif

// constant strings
static NSString * const HROAuthClientIdentifier = @"c367aa7b8c87ce239981140511a7d158";
static NSString * const HROAuthClientSecret = @"bc121c529fcd1689704a24460b91f98b";
static NSString * const HROAuthURLScheme = @"x-org-mitre-hreader";
static NSString * const HROAuthURLHost = @"oauth";
static NSString * const HROAuthKeychainService = @"org.mitre.hreader.refresh-token";

// access token
static NSString *accessToken = nil;
static NSDate *accessTokenExiprationDate = nil;

// request generation queue
static dispatch_queue_t _requestQueue;

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

@interface HROAuthController () {
@private
    UIWebView * __strong webView;
}

/*
 
 Build a form-encoded query string with the given parameters.
 
 */
+ (NSString *)queryStringWithParameters:(NSDictionary *)parameters;

/*
 
 Decode the given query string into a set of parameters.
 
 */
+ (NSDictionary *)parametersFromQueryString:(NSString *)string;

/*
 
 Build the authorization request that is presented to the user through a web
 view.
 
 */
+ (NSURLRequest *)authorizationRequest;

/*
 
 Get the stored refresh token from the keychain.
 
 */
+ (NSString *)refreshToken;

/*
 
 Refresh the stored refresh token, access token, and access token expiration
 date from the given payload.
 
 */
+ (BOOL)refreshAccessTokenWithPayload:(NSDictionary *)payload;

/*
 
 Get the access token payload given the appropriate parameters. This method
 will not execute anything if another request is in 
 
 The parameters dictionary MUST contain the "grant_type" which should be either 
 "authorization_code" or "refresh_token", and the appropriate associated value.
 
 It is up to the caller to validate the returned payload and store any values.
 
 */
+ (NSDictionary *)accessTokenWithParameters:(NSDictionary *)parameters;

/*
 
 
 
 */
+ (void)GETRequestWithPath:(NSString *)path queue:(dispatch_queue_t)queue completion:(void (^) (NSMutableURLRequest *request))block;

@end

@implementation HROAuthController

#pragma mark - class methods

+ (void)initialize {
    if (self == [HROAuthController class]) {
        _requestQueue = dispatch_queue_create("org.mitre.hreader.oauth-request-queue", DISPATCH_QUEUE_SERIAL);
    }
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

+ (NSURLRequest *)authorizationRequest {
    NSString *URLString = [NSString stringWithFormat:@"https://growing-spring-4857.herokuapp.com/oauth2/authorize?client_id=%@&response_type=code", HROAuthClientIdentifier];
    NSURL *URL = [NSURL URLWithString:URLString];
    return [[NSURLRequest alloc] initWithURL:URL];
}

+ (NSString *)refreshToken {
    return [SSKeychain passwordForService:HROAuthKeychainService account:@"default"];
}

+ (BOOL)refreshAccessTokenWithPayload:(NSDictionary *)payload {
    if ([payload objectForKey:@"refresh_token"] && [payload objectForKey:@"expires_in"] && [payload objectForKey:@"access_token"]) {
        [SSKeychain setPassword:[payload objectForKey:@"refresh_token"] forService:HROAuthKeychainService account:@"default"];
        NSTimeInterval interval = [[payload objectForKey:@"expires_in"] doubleValue];
        accessTokenExiprationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
        accessToken = [payload objectForKey:@"access_token"];
        return YES;
    }
    return NO;
}

+ (NSDictionary *)accessTokenWithParameters:(NSDictionary *)parameters {
    
    // build request parameters
    NSMutableDictionary *requestParameters = [parameters mutableCopy];
    [requestParameters setObject:HROAuthClientIdentifier forKey:@"client_id"];
    [requestParameters setObject:HROAuthClientSecret forKey:@"client_secret"];
    NSString *query = [self queryStringWithParameters:requestParameters];
    NSData *data = [query dataUsingEncoding:NSUTF8StringEncoding];
    NSString *length = [NSString stringWithFormat:@"%lu", (unsigned long)[data length]];
    
    // build request
    NSString *URLString = @"https://growing-spring-4857.herokuapp.com/oauth2/token";
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

+ (void)GETRequestWithPath:(NSString *)path completion:(void (^) (NSMutableURLRequest *request))block {
    dispatch_queue_t queue = dispatch_get_current_queue();
    [self GETRequestWithPath:path queue:queue completion:block];
}

+ (void)GETRequestWithPath:(NSString *)path queue:(dispatch_queue_t)queue completion:(void (^) (NSMutableURLRequest *request))block {
    dispatch_async(_requestQueue, ^{
        
        // log initial statement
        NSLog(@"[%@] Building request", NSStringFromClass(self));
        
        // make sure we have a refresh token
        NSString *refresh = [self refreshToken];
        if (!refresh) {
            NSLog(@"[%@] No refresh token is present", NSStringFromClass(self));
            dispatch_async(queue, ^{ block(nil); });
            return;
        }
        
        // used to refresh the access token
        NSTimeInterval interval = [accessTokenExiprationDate timeIntervalSinceNow];
        if (accessTokenExiprationDate) { NSLog(@"[%@] Access token expires in %f minutes", NSStringFromClass(self), interval / 60.0); }
        NSDictionary *refreshParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                           refresh, @"refresh_token",
                                           @"refresh_token", @"grant_type",
                                           nil];
        
        // make sure we have both required elements
        if (!accessToken || !accessTokenExiprationDate || interval < 60.0) {
            NSLog(@"[%@] Access token is invalid -- refreshing...", NSStringFromClass(self));
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
            NSLog(@"[%@] Access token will expire soon -- refreshing", NSStringFromClass(self));
            NSDictionary *payload = [self accessTokenWithParameters:refreshParameters];
            [self refreshAccessTokenWithPayload:payload];
        }
        
        // build request parameters
        NSDictionary *parameters = [NSDictionary dictionaryWithObject:accessToken forKey:@"access_token"];
        NSString *query = [self queryStringWithParameters:parameters];
        NSString *URLString = [NSString stringWithFormat:@"https://%@%@?%@", @"growing-spring-4857.herokuapp.com", path, query];
        NSURL *URL = [NSURL URLWithString:URLString];
        
        // build request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
        [request setHTTPShouldHandleCookies:NO];
        [request setHTTPMethod:@"GET"];
        
        // return
        dispatch_async(queue, ^{ block(request); });
        
    });
}

#pragma mark - object methods

- (id)init {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    webView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    webView.delegate = self;
    [webView loadRequest:[HROAuthController authorizationRequest]];
    [self.view addSubview:webView];
}

- (void)viewDidUnload {
    webView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return  YES;
}

#pragma mark - web view

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *URL = [request URL];
    if ([[URL scheme] isEqualToString:HROAuthURLScheme] && [[URL host] isEqualToString:HROAuthURLHost]) {
        dispatch_async(_requestQueue, ^{
            NSDictionary *parameters = [HROAuthController parametersFromQueryString:[URL query]];
            parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                          [parameters objectForKey:@"code"], @"code",
                          @"authorization_code", @"grant_type",
                          nil];
            NSDictionary *payload = [HROAuthController accessTokenWithParameters:parameters];
            if ([HROAuthController refreshAccessTokenWithPayload:payload]) {
                [self dismissModalViewControllerAnimated:YES];
            }
            else {
                NSLog(@"Error %@ %d", NSStringFromClass([self class]), __LINE__);
            }
        });
    }
    return YES;
}

@end
