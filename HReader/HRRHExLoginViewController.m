//
//  HRRHExLoginViewController.m
//  HReader
//
//  Created by Caleb Davenport on 5/30/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRRHExLoginViewController.h"
#import "HRAPIClient_private.h"
#import "HRPeopleSetupViewController.h"
#import "HRAPIClient_private.h"

#import "CMDActivityHUD.h"

static NSString *HROAuthURLScheme = @"x-org-mitre-hreader";
static NSString *HROAuthURLHost = @"oauth";

@implementation HRRHExLoginViewController {
    HRAPIClient *_client;
    dispatch_queue_t _queue;
}

+ (HRRHExLoginViewController *)loginViewControllerForClient:(HRAPIClient *)client {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"InitialSetup_iPad" bundle:nil];
    HRRHExLoginViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"RHExLoginViewController"];
    controller->_client = client;
    return controller;
}

#pragma mark - object methods

- (void)setQueue:(dispatch_queue_t)queue {
    if (_queue != queue) {
        if (_queue) { dispatch_release(_queue); }
        dispatch_retain(queue);
        _queue = queue;
    }
}

- (void)dealloc {
    dispatch_release(_queue);
}

#pragma mark - view methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [CMDActivityHUD show];
    [self.webView loadRequest:[_client authorizationRequest]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return UIInterfaceOrientationIsLandscape(orientation);
}

#pragma mark - web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    // check headers
    static NSString *targetHeaderFieldValue = @"ipad";
    static NSString *headerFieldKey = @"x-org-mitre-hreader";
    NSString *currentFieldValue = [request valueForHTTPHeaderField:headerFieldKey];
    if (![currentFieldValue isEqualToString:targetHeaderFieldValue]) {
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        [mutableRequest setValue:targetHeaderFieldValue forHTTPHeaderField:headerFieldKey];
        [webView loadRequest:mutableRequest];
        return NO;
    }
    
    NSURL *URL = [request URL];
    if ([[URL scheme] isEqualToString:HROAuthURLScheme] && [[URL host] isEqualToString:HROAuthURLHost]) {
        [CMDActivityHUD show];
        
        // get parameters
        NSDictionary *parameters = [HRAPIClient parametersFromQueryString:[URL query]];
        parameters = @{
            @"code" : [parameters objectForKey:@"code"],
            @"grant_type" : @"authorization_code"
        };
        
        dispatch_async(_queue ?: _client->_requestQueue, ^{
            if ([_client refreshAccessTokenWithParameters:parameters]) {
                dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [self.target performSelector:self.action withObject:self];
#pragma clang diagnostic pop
                });
            }
            else {
                NSLog(@"Error %@ %d", NSStringFromClass([self class]), __LINE__);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc]
                      initWithTitle:@"Unable to get access tokens from server"
                      message:nil
                      delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
                     show];
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [CMDActivityHUD dismiss];
            });
        });
        
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [CMDActivityHUD dismiss];
}

@end
