//
//  C32ViewController.h
//  HReader
//
//  Created by Marshall Huss on 11/18/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface C32ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *toggleButton;
@property (nonatomic) BOOL raw;

- (void)loadFile:(NSString *)fileName withExtension:(NSString *)extension;
- (IBAction)toggleRaw:(id)sender;

@end
