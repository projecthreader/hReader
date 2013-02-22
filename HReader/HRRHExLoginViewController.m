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

@interface HRRHExLoginViewController ()
@property (nonatomic, strong) IBOutlet UIToolbar *navigationToolbar;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, strong) HRAPIClient *client;
@end

@implementation HRRHExLoginViewController

#pragma mark - class methods

+ (HRRHExLoginViewController *)loginViewControllerForClient:(HRAPIClient *)client {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"InitialSetup_iPad" bundle:nil];
    HRRHExLoginViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"RHExLoginViewController"];
    controller.client = client;
    return controller;
}

#pragma mark - object methods

- (IBAction)navigateBack:(id)sender {
    [self.webView goBack];
}

- (IBAction)navigateForward:(id)sender {
    [self.webView goForward];
}

- (IBAction)navigateReload:(id)sender {
    [self.webView reload];
}

#pragma mark - view methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // toolbar
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.navigationToolbar];
    self.navigationItem.leftBarButtonItem = item;
    
    // other
    [CMDActivityHUD show];
    [self.webView loadRequest:[self.client authorizationRequest]];
    
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if ([self.client refreshAccessTokenWithParameters:parameters]) {
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
    NSArray *buttons = self.navigationToolbar.items;
        
    [(UIBarButtonItem *)[buttons objectAtIndex:0] setEnabled:[webView canGoBack]];
    [(UIBarButtonItem *)[buttons objectAtIndex:1] setEnabled:[webView canGoForward]];
    [(UIBarButtonItem *)[buttons objectAtIndex:2] setEnabled:YES];
}

@end
