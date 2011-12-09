//
//  HRTimelineViewController.m
//  HReader
//
//  Created by Marshall Huss on 12/2/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "HRTimelineViewController.h"

@implementation HRTimelineViewController

@synthesize scrollView  = __scrollView;
@synthesize imageView   = __imageView;
@synthesize webView     = __webView;

- (void)dealloc {
    [__scrollView release];
    [__imageView release];
    
    [__webView release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Timeline";
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.scrollView.contentSize = self.imageView.frame.size;
    
    NSURL *html = [[NSBundle mainBundle] URLForResource:@"timeline-index" withExtension:@"html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:html];
    [self.webView loadRequest:request];
    
}

- (void)viewDidUnload {
    self.scrollView = nil;
    self.imageView = nil;
    self.webView = nil;

    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
