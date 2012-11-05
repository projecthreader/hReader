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
 
 Target-action pair to call when authentication is successful. Must take one
 argument that is an instance of this class. This action will be called on the
 main thread.
 
 */
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL action;

/*
 
 Get a new login controller that is setup to talk to the given API client.
 
 */
+ (HRRHExLoginViewController *)loginViewControllerForClient:(HRAPIClient *)client;

@end
