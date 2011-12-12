//
//  HRC32ViewController.m
//  HReader
//
//  Created by Marshall Huss on 12/12/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "HRC32ViewController.h"

@implementation HRC32ViewController

@synthesize webView = __webView;

- (void)dealloc {
    [__webView release];
    [super dealloc];
}

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
    
//    NSURL *html = [[NSBundle mainBundle] URLForResource:@"raw" withExtension:@"html"];    
//    NSURLRequest *request = [NSURLRequest requestWithURL:html];
//    [self.webView loadRequest:request];
    
    
    NSURL *html = [[NSBundle mainBundle] URLForResource:@"Johnny_Smith_96" withExtension:@"html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:html];
    [self.webView loadRequest:request];   
    
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
    

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSURL *xml = [[NSBundle mainBundle] URLForResource:@"Johnny_Smith_96" withExtension:@"xml"];
    NSString *xmlString = [NSString stringWithContentsOfURL:xml encoding:NSUTF8StringEncoding error:nil];    
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"replaceXml('%@');", xmlString]];
}

#pragma mark - IBActions

- (IBAction)done:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
