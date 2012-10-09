//
//  HRRHExLoginViewController.h
//  HReader
//
//  Created by Caleb Davenport on 5/30/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HRAPIClient;

@interface HRRHExLoginViewController : UIViewController <UIWebViewDelegate>

/*
 
 Web view used for user authentication.
 
 */
@property (nonatomic, weak) IBOutlet UIWebView *webView;

/*
 
 Target-action pair to call when authentication is successful. Must take one
 argument that is an instance of this class. This action will be called on the
 main thread.
 
 */
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL action;

/*
 
 
 
 */
+ (HRRHExLoginViewController *)loginViewControllerForClient:(HRAPIClient *)client;

@end
