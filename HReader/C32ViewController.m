//
//  C32ViewController.m
//  HReader
//
//  Created by Marshall Huss on 11/18/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "C32ViewController.h"


@implementation C32ViewController

@synthesize webView         = __webView;
@synthesize toggleButton    = __toggleButton;
@synthesize raw             = __raw;

- (id)init {
    self = [super init];
    if (self) {
        self.raw = NO;
    }
    
    return self;
}

- (void)dealloc {
    [__webView release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self toggleRaw:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.webView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)loadFile:(NSString *)fileName withExtension:(NSString *)extension {
    NSURL *html = [[NSBundle mainBundle] URLForResource:fileName withExtension:extension];
    NSURLRequest *request = [NSURLRequest requestWithURL:html];
    [self.webView loadRequest:request];   
}

- (IBAction)toggleRaw:(id)sender {
    if (self.raw) {
        self.raw = NO;
        self.toggleButton.title = @"HTML";
        [self loadFile:@"Johnny_Smith_96" withExtension:@"xml"];
    } else {
        self.raw = YES;
        self.toggleButton.title = @"XML";
        [self loadFile:@"Johnny_Smith_96" withExtension:@"html"];
        
    }
}


@end
