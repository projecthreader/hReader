//
//  MoCATest.m
//  HReader
//
//  Created by Kiley, Thomas L. on 6/4/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "MoCATest.h"

@implementation MoCATest

@synthesize displayArea;
@synthesize testLabel;
@synthesize nextButton;
@synthesize prevButton;
@synthesize progressBar;

NSMutableArray *pages;
UIStoryboard *mocaTest;
int currentPage;
bool loadOnce = YES;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}


- (void) viewDidLoad {
    
    if (loadOnce) {
        mocaTest = [UIStoryboard storyboardWithName:@"MoCATest" bundle:nil];
        
        pages = [[NSMutableArray alloc] init];
        
        //Add all pages to array
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Executive",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"trace"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Executive",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"cubeDraw"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Naming",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"turtle"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Naming",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"lion"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Naming",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"dog"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Clock Draw",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"clockDraw"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Clock Read",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"clockRead"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Memory",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"wordsPlay"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Attention",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"numberRemember"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Attention",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"numberWrite"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Attention",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"letterF"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Attention",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"letterA"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Attention",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"letterFinal"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Attention",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"subtract7"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Language",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"typeAudio"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Language",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"typeLetterF"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Abstraction",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"similarFruit"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Abstraction",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"similarTransport"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Abstraction",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"similarMeasure"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Delayed Recall",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"recallWords"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Orientation",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"todayDate"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Orientation",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"whereAreYou"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        
        /*
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Results",
                                            [mocaTest instantiateViewControllerWithIdentifier:@"results"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
         */
        
        currentPage = -1;
        [self nextClicked:nil];
        /*[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasShown:) 
                                                     name:UIKeyboardDidShowNotification 
                                                   object:nil];
        [self nextClicked:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:) 
                                                     name:UIKeyboardWillHideNotification 
                                                   object:nil];*/
        loadOnce = NO;
    }
        
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

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
    
    if (currentPage == (int)[pages count] - 1 ) {
        [[self navigationController] pushViewController:[[self storyboard] instantiateViewControllerWithIdentifier:@"results"] animated:YES];
        return;
    }
    
    if (currentPage > (int)[pages count] - 2 ) {
        NSLog(@"Tried to open a page that was too large");
        return;
    }
    
    [[self progressBar] setProgress:(float)currentPage/[pages count] animated:YES];
    
    currentPage++;
    
    if ([[[self displayArea] subviews] count] > 0)
         [[[[self displayArea] subviews] objectAtIndex:0] removeFromSuperview];
    
    [[self displayArea] addSubview:[[[pages objectAtIndex:currentPage] objectForKey:@"ViewController"] view]];
    [[self testLabel] setText:[[pages objectAtIndex:currentPage] objectForKey:@"Name"]];
    
    [[self prevButton] setEnabled:YES];
    
    /*
    if (currentPage == (int)[pages count]) {
        //Disable Next
        [[self nextButton] setEnabled:NO];
    }
    */
    
    
    //Things which don't work...
    //[self setView:[[[pages objectAtIndex:0] objectForKey:@"ViewController"] view]];
    //[[self view] addSubview:[[[pages objectAtIndex:0] objectForKey:@"ViewController"] view]];
    //[self setView:NULL];
    //[[self navigationController] pushViewController:[[pages objectAtIndex:0] objectForKey:@"ViewController"] animated:YES];
    //[self presentViewController:[[pages objectAtIndex:0] objectForKey:@"ViewController"] animated:YES completion:nil];
}

- (IBAction) prevClicked: (id)sender {
    
    if (currentPage < 1 ) {
        NSLog(@"Tried to open a page that was too small");
        return;
    }
    
    currentPage--;
    
    if ([[[self displayArea] subviews] count] > 0)
        [[[[self displayArea] subviews] objectAtIndex:0] removeFromSuperview];
    
    [[self displayArea] addSubview:[[[pages objectAtIndex:currentPage] objectForKey:@"ViewController"] view]];
    [[self testLabel] setText:[[pages objectAtIndex:currentPage] objectForKey:@"Name"]];
    
    [[self nextButton] setEnabled:YES];
    
    if (currentPage == 0) {
        //Disable Next
        [[self prevButton] setEnabled:NO];
    }
    
}

/*- (IBAction) shiftDisplayUp: (id) sender {
    //http://www.iphonedevsdk.com/forum/iphone-sdk-tutorials/32204-moving-uitextfield-when-keyboard-pops-up.html
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];

    textfield.frame = CGRectMake(textfield.frame.origin.x, (textfield.frame.origin.y + 100.0), textfield.frame.size.width, textfield.frame.size.height);
    //Might have to do something else here to select the right page
    [UIView commitAnimations];
}

- (IBAction) shiftDisplayDOwn: (id) sender {
    
}*/

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
    [testLabel release];
    [displayArea release];
    [nextButton release];
    [prevButton release];
    [progressBar release];
    [super dealloc];
}
@end
