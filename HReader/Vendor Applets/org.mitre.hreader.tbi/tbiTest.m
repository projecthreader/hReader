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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}


//debugging
- (UIColor *)randomColor
{
    CGFloat red = (arc4random()%256)/256.0;
    CGFloat green = (arc4random()%256)/256.0;
    CGFloat blue = (arc4random()%256)/256.0;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

- (void) viewDidLoad {
    NSLog(@"viewDidLoad called");
    
    //debugging
    /*
    self.view.layer.borderColor = [self randomColor].CGColor;
    self.view.layer.borderWidth = 1.0;
    
    for (UIView *subview in self.view.subviews)
    {
        subview.layer.borderColor = [self randomColor].CGColor;
        subview.layer.borderWidth = 5.0;
        for (UIView *subview2 in subview.subviews){
            subview2.layer.borderColor = [self randomColor].CGColor;
            subview2.layer.borderWidth = 4.0;
            for (UIView *subview3 in subview2.subviews){
                subview3.layer.borderColor = [self randomColor].CGColor;
                subview3.layer.borderWidth = 3.0;
                for (UIView *subview4 in subview3.subviews){
                    subview4.layer.borderColor = [self randomColor].CGColor;
                    subview4.layer.borderWidth = 2.0;
                    for (UIView *subview5 in subview4.subviews){
                        subview5.layer.borderColor = [self randomColor].CGColor;
                        subview5.layer.borderWidth = 1.0;
                    }
                }
            }
        }
    }
    */
    
    if (loadOnce) {
        tbiTestStoryboard = [UIStoryboard storyboardWithName:@"tbiTest" bundle:nil];
        
        pages = [[NSMutableArray alloc] init];
        
        //Add all pages to array
        /*
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Executive",
                                            [tbiTest instantiateViewControllerWithIdentifier:@"trace"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Executive",
                                            [tbiTest instantiateViewControllerWithIdentifier:@"cubeDraw"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Naming",
                                            [tbiTest instantiateViewControllerWithIdentifier:@"turtle"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Naming",
                                            [tbiTest instantiateViewControllerWithIdentifier:@"lion"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Naming",
                                            [tbiTest instantiateViewControllerWithIdentifier:@"dog"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Clock Draw",
                                            [tbiTest instantiateViewControllerWithIdentifier:@"clockDraw"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Clock Read",
                                            [tbiTest instantiateViewControllerWithIdentifier:@"clockRead"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
         */
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
        /*
        [pages addObject:[[NSMutableDictionary alloc]
                          initWithObjects: [NSArray arrayWithObjects:@"PRMQ #1",
                                            [tbiTestStoryboard instantiateViewControllerWithIdentifier:@"prmq1"]
                                            ,nil]
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc]
                          initWithObjects: [NSArray arrayWithObjects:@"PRMQ #2",
                                            [tbiTestStoryboard instantiateViewControllerWithIdentifier:@"prmq2"]
                                            ,nil]
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc]
                          initWithObjects: [NSArray arrayWithObjects:@"PRMQ #3",
                                            [tbiTestStoryboard instantiateViewControllerWithIdentifier:@"prmq3"]
                                            ,nil]
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        */
        
        /*
        [pages addObject:[[NSMutableDictionary alloc]
                          initWithObjects: [NSArray arrayWithObjects:@"Attention",
                                            [tbiTest instantiateViewControllerWithIdentifier:@"numberRemember"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Attention",
                                            [tbiTest instantiateViewControllerWithIdentifier:@"numberWrite"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Attention",
                                            [tbiTest instantiateViewControllerWithIdentifier:@"letterF"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Attention",
                                            [tbiTest instantiateViewControllerWithIdentifier:@"letterA"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Attention",
                                            [tbiTest instantiateViewControllerWithIdentifier:@"letterFinal"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Attention",
                                            [tbiTest instantiateViewControllerWithIdentifier:@"subtract7"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Language",
                                            [tbiTest instantiateViewControllerWithIdentifier:@"typeAudio"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Language",
                                            [tbiTest instantiateViewControllerWithIdentifier:@"typeLetterF"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Abstraction",
                                            [tbiTest instantiateViewControllerWithIdentifier:@"similarFruit"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Abstraction",
                                            [tbiTest instantiateViewControllerWithIdentifier:@"similarTransport"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Abstraction",
                                            [tbiTest instantiateViewControllerWithIdentifier:@"similarMeasure"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Delayed Recall",
                                            [tbiTest instantiateViewControllerWithIdentifier:@"recallWords"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Orientation",
                                            [tbiTest instantiateViewControllerWithIdentifier:@"todayDate"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Orientation",
                                            [tbiTest instantiateViewControllerWithIdentifier:@"whereAreYou"]
                                            ,nil] 
                          forKeys:[NSArray arrayWithObjects:@"Name",
                                   @"ViewController",
                                   nil]
                          ]];
        
        */
        /*
        [pages addObject:[[NSMutableDictionary alloc] 
                          initWithObjects: [NSArray arrayWithObjects:@"Results",
                                            [tbiTest instantiateViewControllerWithIdentifier:@"results"]
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
    
    if (currentPage == (int)[pages count]) {
        int finalScore = 0;
        int prmqScore = 0;
        UIViewController *currentVC;
        for(int i = 0; i<(int)[pages count]; i++){
            currentVC = [[pages objectAtIndex:i] valueForKey:@"ViewController"];
            if ([currentVC isKindOfClass:[PRMQViewController class]]) {
                prmqScore += (int)[[[pages objectAtIndex:i] valueForKey:@"ViewController"] result];
            }
            else{
                finalScore += (int)[[[pages objectAtIndex:i] valueForKey:@"ViewController"] result];
            }
            //NSLog(@"So far: %i and %i", finalScore, prmqScore);
        }
        [[self finalScoreLabel] setText:[NSString stringWithFormat:@"%i/5",finalScore]];
        [[self PRMQScoreLabel] setText:[NSString stringWithFormat:@"%i",prmqScore]];
    }
    
    //NSLog(@"%@", [[self view] recursiveDescription]);
    
    /*
    self.view.layer.borderColor = [UIColor redColor].CGColor;
    self.view.layer.borderWidth = 5.0;
    for (UIView *subview in self.view.subviews)
    {
        subview.layer.borderColor = [UIColor blueColor].CGColor;
        subview.layer.borderWidth = 4.0;
        //subview.layer.bounds = CGRectMake(textfield.frame.origin.x, (textfield.frame.origin.y + 100.0), textfield.frame.size.width, textfield.frame.size.height);
        for (UIView *subview2 in subview.subviews){
            subview2.layer.borderColor = [UIColor greenColor].CGColor;
            subview2.layer.borderWidth = 3.0;
            for (UIView *subview3 in subview2.subviews){
                subview3.layer.borderColor = [UIColor redColor].CGColor;
                subview3.layer.borderWidth = 2.0;
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
    
    //NSLog(@"nextClicked");
    
    if (currentPage == (int)[pages count] - 1 ) {
        currentPage++;
        NSLog(@"resultsPage");
        
        tbiTest* resultViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"results"];

        /*
        int finalScore = 0;
        for(int i = 0; i<(int)[pages count]; i++){
            finalScore += (int)[[[pages objectAtIndex:i] valueForKey:@"ViewController"] result];
        }
        [[resultViewController finalScoreLabel] setText:[NSString stringWithFormat:@"%i/5",finalScore]];
        */
         
        [[self navigationController] pushViewController:resultViewController animated:YES];
        return;
    }
    
    if (currentPage > (int)[pages count] - 2 ) {
        NSLog(@"Tried to open a page that was too large");
        return;
    }
    
    //NSLog(@"Setting progress to: %i/%i = %f", currentPage+1, [pages count], (float)(currentPage+1)/(float)[pages count]);
    [[self progressBar] setProgress:(float)(currentPage+1)/(float)[pages count] animated:YES];
    
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
