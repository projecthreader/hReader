//
//  tbiTest.m
//  HReader
//
//  Created by Kiley, Thomas L. on 6/4/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "tbiTest.h"

@implementation tbiTest

@synthesize displayArea;
@synthesize testLabel;
@synthesize nextButton;
@synthesize prevButton;
@synthesize progressBar;

@synthesize finalScoreLabel;

NSMutableArray *pages;
UIStoryboard *tbiTestStoryboard;
//UILabel *finalScoreLabel;
int currentPage;
bool loadOnce = YES;
UIViewController *currentVC;
Stopwatch *stopwatch;

UIView *topView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}


//debugging


- (void) viewDidLoad {
    NSLog(@"viewDidLoad called, with loadOnce = %i", loadOnce);
    
    if (loadOnce) {
        
        tbiTestStoryboard = [UIStoryboard storyboardWithName:@"tbiTest" bundle:nil];
        
        pages = [[NSMutableArray alloc] init];
        
         [pages addObject:[[NSMutableDictionary alloc]
                          initWithObjects: [NSArray arrayWithObjects:@"Memory",
                                            [tbiTestStoryboard instantiateViewControllerWithIdentifier:@"wordsPlay"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        
        for(int i=1; i<16; i++){
            [pages addObject:[[NSMutableDictionary alloc]
                              initWithObjects: [NSArray arrayWithObjects:[NSString stringWithFormat:@"PRMQ Question #%i", i],
                                                [tbiTestStoryboard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"prmq%i", i]]
                                                ,nil]
                              forKeys:[NSArray arrayWithObjects:@"Name",
                                       @"ViewController",
                                       nil]
                              ]];
        }
        [pages addObject:[[NSMutableDictionary alloc]
                          initWithObjects: [NSArray arrayWithObjects:@"Results",
                                            [tbiTestStoryboard instantiateViewControllerWithIdentifier:@"resultsPage"]
                                            ,nil]
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        
        currentPage = -1;
        [self nextClicked:nil];
        
        stopwatch = [Stopwatch new];
        [stopwatch start];
        NSLog(@"stopWatch status: %@", stopwatch);
        
        loadOnce = NO;
    }
    
    /*
    self.view.layer.borderColor = [UIColor redColor].CGColor;
    self.view.layer.borderWidth = 3.0;
    for (UIView *subview in self.view.subviews)
    {
        subview.layer.borderColor = [UIColor blueColor].CGColor;
        subview.layer.borderWidth = 2.0;
        //subview.layer.bounds = CGRectMake(textfield.frame.origin.x, (textfield.frame.origin.y + 100.0), textfield.frame.size.width, textfield.frame.size.height);
        for (UIView *subview2 in subview.subviews){
            subview2.layer.borderColor = [UIColor greenColor].CGColor;
            subview2.layer.borderWidth = 1.0;
            for (UIView *subview3 in subview2.subviews){
                subview3.layer.borderColor = [UIColor redColor].CGColor;
                subview3.layer.borderWidth = 1.0;
                //subview3.layer.frame = CGRectMake(0, 0, 976, 384);
                for (UIView *subview4 in subview3.subviews){
                    subview4.layer.borderColor = [UIColor blueColor].CGColor;
                    subview4.layer.borderWidth = 1.0;
                    for (UIView *subview5 in subview4.subviews){
                        subview5.layer.borderColor = [self randomColor].CGColor;
                        subview5.layer.borderWidth = 1.0;
                    }
                }
            }
        }
    }
     */
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    self.progressBar.frame = CGRectMake(700, 100, 300, 50);
    self.progressBar.transform = CGAffineTransformScale(self.progressBar.transform, 1.0, 2.0);
    //NSLog(@"size of frame is: %f, %f", self.progressBar.frame.size.width, self.progressBar.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [self setTestLabel:nil];
    [self setDisplayArea:nil];
    [self setNextButton:nil];
    [self setPrevButton:nil];
    [self setProgressBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction) nextClicked: (id)sender {
    currentPage++;
    //NSLog(@"Current page is: %i, [pages count] is: %i", currentPage, [pages count]);

    
    if (currentPage == (int)[pages count] - 0 ) {
        [[self navigationController] popViewControllerAnimated:YES];
        return;
    }
    
    if (currentPage > (int)[pages count] - 1 ) {
        NSLog(@"Tried to open a page that was too large");
        return;
    }
    
    //NSLog(@"Setting progress to: %i/%i = %f", currentPage+1, [pages count], (float)(currentPage+1)/(float)[pages count]);
    [[self progressBar] setProgress:(float)(currentPage+1)/(float)([pages count]-1) animated:YES];
    
    
    //NSLog(@"nextClicked called. Returning next page. CurrentPage = %i", currentPage);
    
    if ([[[self displayArea] subviews] count] > 0)
         [[[[self displayArea] subviews] objectAtIndex:0] removeFromSuperview];
    
    [[self displayArea] addSubview:[[[pages objectAtIndex:currentPage] objectForKey:@"ViewController"] view]];
    [[self testLabel] setText:[[pages objectAtIndex:currentPage] objectForKey:@"Name"]];
    if (currentPage == (int)[pages count] - 1) {
        NSLog(@"This is the results page.");
        NSLog(@"Stopwatch status: %@", stopwatch);
        NSLog(@"Stopwatch says: %@", [stopwatch description]);
        [stopwatch stop];
        NSLog(@"Stopwatch status: %@", stopwatch);
        NSLog(@"Stopwatch says: %@", [stopwatch description]);
        //topView = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
        //NSLog(@"topview = %@", topView);
        currentVC = [[pages objectAtIndex:currentPage] valueForKey:@"ViewController"];
        if ([currentVC isKindOfClass:[ResultViewController class]]) {
            int testScore = 0;
            int prmqScore = 0;
            for(int i = 0; i<(int)[pages count]; i++){
                currentVC = [[pages objectAtIndex:i] valueForKey:@"ViewController"];
                if ([currentVC isKindOfClass:[PRMQViewController class]]) {
                    prmqScore += (int)[[[pages objectAtIndex:i] valueForKey:@"ViewController"] result];
                }
                else if ([currentVC isKindOfClass:[tbiTestMemoryViewController class]]){
                    testScore += (int)[[[pages objectAtIndex:i] valueForKey:@"ViewController"] result];
                }
            }
            [(ResultViewController *)currentVC setTestResult:testScore outOf:5 andPRMQResult:prmqScore];
        }
        
    }
    
    [[self prevButton] setEnabled:YES];
    
    
    
    /*
    if (currentPage == (int)[pages count]) {
        //Disable Next
        [[self nextButton] setEnabled:NO];
    }
    */
}

- (IBAction) prevClicked: (id)sender {
    if (currentPage < 1 ) {
        NSLog(@"Tried to open a page that was too small");
        return;
    }
    
    currentPage--;
    NSLog(@"prevClicked called. CurrentPage = %i", currentPage);
    
    if ([[[self displayArea] subviews] count] <= 0)
        [[[[self displayArea] subviews] objectAtIndex:0] removeFromSuperview];
    
    [[self displayArea] addSubview:[[[pages objectAtIndex:currentPage] objectForKey:@"ViewController"] view]];
    [[self testLabel] setText:[[pages objectAtIndex:currentPage] objectForKey:@"Name"]];
    
    [[self nextButton] setEnabled:YES];
    
    if (currentPage == 0) {
        //Disable Next
        [[self prevButton] setEnabled:NO];
    }
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {	
    NSLog(@"Began editing");
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationBeginsFromCurrentState:YES];
	textField.frame = CGRectMake(textField.frame.origin.x, (textField.frame.origin.y - 100.0), textField.frame.size.width, textField.frame.size.height);
	[UIView commitAnimations];
}


- (void)textFieldDidEndEditing:(UITextField *)textField {	
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationBeginsFromCurrentState:YES];
	textField.frame = CGRectMake(textField.frame.origin.x, (textField.frame.origin.y + 100.0), textField.frame.size.width, textField.frame.size.height);
	[UIView commitAnimations];
}


- (void)dealloc {
    NSLog(@"dealloc called");
    loadOnce = YES;
    [testLabel release];
    [displayArea release];
    [nextButton release];
    [prevButton release];
    [progressBar release];
    [super dealloc];
}
@end
