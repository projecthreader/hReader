//
//  HRRHExLoginViewController.h
//  HReader
//
//  Created by Caleb Davenport on 5/30/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRRHExLoginViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;

+ (HRRHExLoginViewController *)loginViewControllerWithHost:(NSString *)host;

@end
