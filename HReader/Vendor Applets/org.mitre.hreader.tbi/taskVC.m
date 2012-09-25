//
//  taskVC.m
//  HReader
//
//  Created by Saltzman, Shep on 9/21/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "taskVC.h"

@implementation taskVC

int currentImage;

- (IBAction) nextClicked: (id)sender{
    NSLog(@"Next clicked");
    currentImage += 1;
    if (currentImage > 11){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        NSString *imageName = [NSString stringWithFormat:@"scene%i", currentImage];
        UIImage *nextImage = [UIImage imageNamed:imageName];
        [[self button] setImage:nextImage forState:0];
    }
    
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
    currentImage = 1;
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

@end
