//
//  HRC32ViewController.m
//  HReader
//
//  Created by Marshall Huss on 12/12/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "HRC32ViewController.h"

#import "HRMPatient.h"

@implementation HRC32ViewController

@synthesize webView = __webView;

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.title = @"C32 HTML";
    }
    return self;
}
- (void)dealloc {
    self.webView = nil;
    [super dealloc];
}

#pragma mark - view methods

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *URL = [[HRMPatient selectedPatient] C32HTMLURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [self.webView loadRequest:request];
}
- (void)viewDidUnload {
    [super viewDidUnload];
    self.webView = nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark - button actions

- (IBAction)done {
    [self dismissModalViewControllerAnimated:YES];
}

@end
