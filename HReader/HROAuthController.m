//
//  HROAuthController.m
//  HReader
//
//  Created by Caleb Davenport on 5/23/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HROAuthController.h"

#import "GCOAuth.h"

static NSString * const OAuthClientIdentifier = @"c367aa7b8c87ce239981140511a7d158";
static NSString * const OAuthClientSecret = @"bc121c529fcd1689704a24460b91f98b";
static NSString * const OAuthURLScheme = @"x-org-mitre-hreader";

@interface HROAuthController () {
@private
    UIWebView *webView;
}

@end

@implementation HROAuthController

+ (NSURLRequest *)authorizationRequest {
//    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
//                                OAuthClientIdentifier, @"client_id",
//                                nil];
//    NSString *query = [GCOAuth queryStringFromParameters:parameters];
    NSString *URLString = [NSString stringWithFormat:@"https://growing-spring-4857.herokuapp.com/oauth2/authorize?client_id=%@&response_type=code", OAuthClientIdentifier];
    NSURL *URL = [NSURL URLWithString:URLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    return request;
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [request setHTTPMethod:@"GET"];
}

+ (NSString *)accessTokenWithCode:(NSString *)code {
    //    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
    //                                OAuthClientIdentifier, @"client_id",
    //                                nil];
    //    NSString *query = [GCOAuth queryStringFromParameters:parameters];
    NSString *URLString = [NSString stringWithFormat:
                           @"https://growing-spring-4857.herokuapp.com/oauth2/token?client_id=%@&client_secret=%@&code=%@",
                           OAuthClientIdentifier,
                           OAuthClientSecret,
                           code];
    NSURL *URL = [NSURL URLWithString:URLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setValue:@"application/xml" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *body = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"%@", response);
    NSLog(@"%@", error);
    NSLog(@"%@", [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding]);
    
    return nil;
}

+ (void)getRequestTokens {

//    NSLog(@"%@", URLString);

//    NSHTTPURLResponse *response = nil;
//    NSError *error = nil;
//    NSData *body = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    NSLog(@"%@", response);
//    NSLog(@"%@", error);
//    NSLog(@"%@", [[[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding] autorelease]);
}

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
    if ([[URL scheme] isEqualToString:OAuthURLScheme]) {
//        NSLog([URL query]);
        [HROAuthController accessTokenWithCode:[[[URL query] componentsSeparatedByString:@"="] objectAtIndex:1]];
        [self dismissModalViewControllerAnimated:YES];
    }
    return YES;
}

@end
