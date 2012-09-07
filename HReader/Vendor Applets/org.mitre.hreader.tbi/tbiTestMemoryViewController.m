//
//  tbiTestMemoryViewController.m
//  HReader
//
//  Created by Saltzman, Shep on 8/16/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "tbiTestMemoryViewController.h"

@interface tbiTestMemoryViewController ()

@end

@implementation tbiTestMemoryViewController

@synthesize scrollView;

UITextField *activeField;

- (IBAction) playSound: (id)sender {
    NSLog(@"playSound called");
    
    SystemSoundID soundID = 0;
    //NSString* str = [[NSBundle mainBundle] pathForResource:@"Memory_List1" ofType:@"m4a"];
    NSURL* soundFileURL = [[NSBundle mainBundle] URLForResource:@"Memory_List1" withExtension:@"m4a"];

    //CFURLRef soundFileURL = (CFURLRef)[NSURL URLWithString:str];
    //NSLog(@"attempting to play soundfile at URL: %@", CFUrlGetString(soundFileURL));
    //NSLog(@"resolved to URL: %@", soundFileURL);
    OSStatus errorCode = AudioServicesCreateSystemSoundID((CFURLRef)soundFileURL , &soundID);
    if(errorCode != 0){
        NSLog(@"soundfile failed to play with errorcode: %ld", errorCode);
    }
    else{
        AudioServicesPlaySystemSound(soundID);
    }
    
    [self.playButton setEnabled:NO];
}

- (int)result{
    //NSLog(@"reached MemoryViewController result function");
    NSArray* answers = [[NSArray alloc] initWithObjects:@"one", @"two", @"three", @"four", @"five", nil];
    
    int result = 0;

    if([[[[self memory_word_recall_field1] text] lowercaseString] isEqualToString: [answers objectAtIndex:0]]){
        //NSLog(@"correct!");
        result++;
    }
    if([[[[self memory_word_recall_field2] text] lowercaseString] isEqualToString: [answers objectAtIndex:1]]){
        //NSLog(@"correct!");
        result++;
    }
    if([[[[self memory_word_recall_field3] text] lowercaseString] isEqualToString: [answers objectAtIndex:2]]){
        //NSLog(@"correct!");
        result++;
    }
    if([[[[self memory_word_recall_field4] text] lowercaseString] isEqualToString: [answers objectAtIndex:3]]){
        //NSLog(@"correct!");
        result++;
    }
    if([[[[self memory_word_recall_field5] text] lowercaseString] isEqualToString: [answers objectAtIndex:4]]){
        //NSLog(@"correct!");
        result++;
    }
    return result;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
    self.view.frame = CGRectMake(0, 0, 1024, 384);
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    //NSLog(@"field was shown");

    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect bkgndRect = activeField.superview.frame;
    bkgndRect.size.height += kbSize.height;
    [activeField.superview setFrame:bkgndRect];
    [scrollView setContentOffset:CGPointMake(0.0, activeField.frame.origin.y+25) animated:YES];
     
    //[scrollView setContentOffset:CGPointMake(0.0, activeField.frame.origin.y-kbSize.height) animated:YES];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{

    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect bkgndRect = activeField.superview.frame;
    bkgndRect.size.height += kbSize.height;
    [activeField.superview setFrame:bkgndRect];
    [scrollView setContentOffset:CGPointMake(0.0, activeField.frame.origin.y-25) animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

@end
