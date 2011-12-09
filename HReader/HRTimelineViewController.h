//
//  HRTimelineViewController.h
//  HReader
//
//  Created by Marshall Huss on 12/2/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRTimelineViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UIWebView *webView;

@end
