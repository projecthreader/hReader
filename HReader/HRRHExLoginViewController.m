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

#import "CMDActivityHUD.h"

static NSString * const HROAuthURLScheme = @"x-org-mitre-hreader";
static NSString * const HROAuthURLHost = @"oauth";

@interface HRRHExLoginViewController () {
@private
    NSString *_host;
}

@end

@implementation HRRHExLoginViewController

@synthesize webView = _webView;

+ (HRRHExLoginViewController *)loginViewControllerWithHost:(NSString *)host {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"InitialSetup_iPad" bundle:nil];
    HRRHExLoginViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"RHExLoginViewController"];
    controller->_host = [host copy];
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [CMDActivityHUD show];
    HRAPIClient *client = [HRAPIClient clientWithHost:_host];
    [self.webView loadRequest:[client authorizationRequest]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return UIInterfaceOrientationIsLandscape(orientation);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *URL = [request URL];
    if ([[URL scheme] isEqualToString:HROAuthURLScheme] && [[URL host] isEqualToString:HROAuthURLHost]) {
        [CMDActivityHUD show];
        HRAPIClient *client = [HRAPIClient clientWithHost:_host];
        dispatch_async(client->_requestQueue, ^{
            NSDictionary *parameters = [HRAPIClient parametersFromQueryString:[URL query]];
            parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                          [parameters objectForKey:@"code"], @"code",
                          @"authorization_code", @"grant_type",
                          nil];
            if ([client refreshAccessTokenWithParameters:parameters]) {
                HRPeopleSetupViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PeopleSetupViewController"];
                controller.navigationItem.hidesBackButton = YES;
                [self.navigationController pushViewController:controller animated:YES];
            }
            else {
                NSLog(@"Error %@ %d", NSStringFromClass([self class]), __LINE__);
                [[[UIAlertView alloc]
                  initWithTitle:@"Unable to get access tokens from server"
                  message:nil
                  delegate:nil
                  cancelButtonTitle:@"OK"
                  otherButtonTitles:nil]
                 show];
            }
            [CMDActivityHUD dismiss];
        });
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [CMDActivityHUD dismiss];
}

@end
