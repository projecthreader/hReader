//
//  TimelineViewController.m
//  HReader
//
//  Created by Marshall Huss on 11/28/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "TimelineViewController.h"

@implementation TimelineViewController
@synthesize webView = __webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://oreilly.com/news/graphics/prog_lang_poster.pdf"]]];
    
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc {
    [__webView release];
    [super dealloc];
}
@end
