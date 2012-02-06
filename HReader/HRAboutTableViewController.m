//
//  HRAboutTableViewController.m
//  HReader
//
//  Created by Marshall Huss on 12/12/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "HRAboutTableViewController.h"
#import "HRPasscodeWarningViewController.h"

#import "PINCodeViewController.h"

@implementation HRAboutTableViewController

@synthesize versionLabel = __versionLabel;
@synthesize aboutLabel = __aboutLabel;

- (void)dealloc {
    [__versionLabel release];
    [__aboutLabel release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

    self.versionLabel.text = [HRConfig formattedVersion];
//    self.aboutLabel.text = @"\nThe MITRE Corporation c2012\n\nhReader prototype demonstration application.\nAll data contained in this application is synthetic and fictional for research purposes.";
}

- (void)viewDidUnload
{
    self.versionLabel = nil;
    self.aboutLabel = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}
 */

/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}
 */

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    /*if (indexPath.row == 0) {
//        [TestFlight openFeedbackView];         
    } else if (indexPath.row == 1) {
//        HRPasscodeWarningViewController *warningViewController = [[HRPasscodeWarningViewController alloc] initWithNibName:nil bundle:nil];
//        warningViewController.demoMode = YES;
//        [self presentModalViewController:warningViewController animated:YES];
//        [warningViewController release];
    }
    
    // passcode cell
    else*/ if ([cell.reuseIdentifier isEqualToString:@"ChangePasscodeCell"]) {
        
        // get storyboard
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PINCodeStoryboard" bundle:nil];
        
        // load up view controller
        UINavigationController *verifyNavigation = [storyboard instantiateInitialViewController];
        PINCodeViewController *verifyController = [verifyNavigation.viewControllers objectAtIndex:0];
        verifyController.mode = PINCodeViewControllerModeVerify;
        verifyController.title = @"Enter Passcode";
        verifyController.messageText = @"Enter your passcode";
        verifyController.errorText = @"Incorrect passcode";
        verifyController.automaticallyDismissWhenValid = NO;
        verifyController.verifyBlock = ^(NSString *code) {
            if ([PINCodeViewController isPasscodeValid:code]) {
                
                // load up create controller
                UINavigationController *createNavigation = [storyboard instantiateInitialViewController];
                PINCodeViewController *createController = [createNavigation.viewControllers objectAtIndex:0];
                createController.mode = PINCodeViewControllerModeCreate;
                createController.title = @"Set Passcode";
                createController.messageText = @"Enter a passcode";
                createController.confirmText = @"Verify passcode";
                createController.errorText = @"The passcodes do not match";
                createController.automaticallyDismissWhenValid = NO;
                createController.verifyBlock = ^(NSString *code) {
                    if ([code length] == 6) {
                        [PINCodeViewController setPersistedPasscode:code];
                        [self dismissModalViewControllerAnimated:YES];
                        return YES;
                    }
                    else {
                        return NO;
                    }
                };
                [verifyController presentModalViewController:createNavigation animated:NO];
                
                // return
                return YES;
                
            }
            else {
                return NO;
            }
        };
        [self presentModalViewController:verifyNavigation animated:YES];
    }

}


#pragma mark - IBActions

- (IBAction)done:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
