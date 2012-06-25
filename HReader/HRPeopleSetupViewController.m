//
//  HRPeopleSetupViewController.m
//  HReader
//
//  Created by Caleb Davenport on 5/29/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRPeopleSetupViewController.h"
#import "HRAppDelegate.h"
#import "HRPeopleSetupTileView.h"
#import "HRPeopleFeedViewController.h"
#import "HRAPIClient.h"
#import "HRPeoplePickerViewController_private.h"

#import "HRMPatient.h"

#import "SVPanelViewController.h"

#import "GCAlertView.h"

#define kDeleteButtonViewTag 100

@interface HRPeopleSetupViewController () {
@private
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    UIPopoverController *_popoverController;
    UINib *nib;
}

- (void)presentPopoverFromButton:(UIButton *)button
                       withTitle:(NSString *)title
                    relationship:(HRMPatientRelationship)relationship
                      completion:(void (^) (void))completion;

- (void)showMainApplicationInterface;

- (void)adjustUserInterfaceForPatients:(BOOL)animated;

@end

@implementation HRPeopleSetupViewController

@synthesize gridView = _gridView;
@synthesize emptyCellView = _emptyCellView;
@synthesize spouseButton = _spouseButton;
@synthesize emptyCellButtons = _emptyCellButtons;
@synthesize firstView = _firstView;
@synthesize meButton = _meButton;

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        nib = [UINib nibWithNibName:@"HRPeopleSetupTileView" bundle:nil];
        managedObjectContext = [HRAppDelegate managedObjectContext];
        NSFetchRequest *request = [HRMPatient fetchRequestInContext:managedObjectContext];
        NSArray *descriptors = [NSArray arrayWithObjects:
                                [NSSortDescriptor sortDescriptorWithKey:@"displayOrder" ascending:YES],
                                [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES],
                                [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES],
                                nil];
        [request setSortDescriptors:descriptors];
        fetchedResultsController = [[NSFetchedResultsController alloc]
                                    initWithFetchRequest:request
                                    managedObjectContext:managedObjectContext
                                    sectionNameKeyPath:nil
                                    cacheName:nil];
        fetchedResultsController.delegate = self;
        [fetchedResultsController performFetch:nil];
    }
    return self;
}

- (void)presentPopoverFromButton:(UIButton *)button
                       withTitle:(NSString *)title
                    relationship:(HRMPatientRelationship)relationship
                      completion:(void (^) (void))completion {
    
    // get api client
    NSString *host = [[HRAPIClient hosts] lastObject];
    HRAPIClient *client = [HRAPIClient clientWithHost:host];
    
    // create controller
    HRPeopleFeedViewController *controller = [[HRPeopleFeedViewController alloc] initWithHost:host];
    controller.title = title;
    controller.didFinishBlock = ^(NSString *identifier) {
        [client JSONForPatientWithIdentifier:identifier finishBlock:^(NSDictionary *payload) {
            if (payload) {
                NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
                [context setPersistentStoreCoordinator:[HRAppDelegate persistentStoreCoordinator]];
                HRMPatient *patient = [HRMPatient instanceInContext:context];
                [patient populateWithContentsOfDictionary:payload];
                patient.serverID = identifier;
                patient.host = host;
                patient.relationship = [NSNumber numberWithShort:relationship];
                [context save:nil];
            }
            else {
                NSString *message = [NSString stringWithFormat:
                                     @"An error occurred while fetching the patient from %@",
                                     host];
                [[[UIAlertView alloc]
                  initWithTitle:@"Error"
                  message:message
                  delegate:nil
                  cancelButtonTitle:@"OK"
                  otherButtonTitles:nil]
                 show];
            }
        }];
        [_popoverController dismissPopoverAnimated:YES];
        if (completion) { completion(); }
    };
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    navigation.toolbarHidden = NO;
    
    // show controller
    if (_popoverController == nil) {
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:navigation];
    }
    else { _popoverController.contentViewController = navigation; }
    [_popoverController
     presentPopoverFromRect:button.frame
     inView:button.superview
     permittedArrowDirections:UIPopoverArrowDirectionAny
     animated:YES];
    
}

- (void)showMainApplicationInterface {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    SVPanelViewController *panel = [storyboard instantiateInitialViewController];
    panel.mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"RootViewController"];
    panel.rightAccessoryViewController = [storyboard instantiateViewControllerWithIdentifier:@"AppletsConfigurationViewController"];
    panel.leftAccessoryViewController = [storyboard instantiateViewControllerWithIdentifier:@"PeoplePickerViewController"];
    [self presentViewController:panel animated:YES completion:nil];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.gridView reloadData];
}

- (void)adjustUserInterfaceForPatients:(BOOL)animated {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"relationship = %d", HRMPatientRelationshipMe];
    void (^animations) (void) = nil;
    if ([HRMPatient countInContext:[HRAppDelegate managedObjectContext] withPredicate:predicate] == 0) {
        self.navigationItem.rightBarButtonItem = nil;
        self.editing = NO;
        animations = ^{
            CGRect frame = self.view.bounds;
            self.firstView.frame = frame;
            self.firstView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
            frame = CGRectOffset(frame, 0.0, CGRectGetHeight(frame));
            self.gridView.frame = frame;
            self.gridView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                              UIViewAutoresizingFlexibleTopMargin |
                                              UIViewAutoresizingFlexibleHeight);
        };
    }
    else {
        self.navigationItem.rightBarButtonItem = [self editButtonItem];
        animations = ^{
            CGRect frame = self.view.bounds;
            self.gridView.frame = frame;
            self.gridView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
            frame = CGRectOffset(frame, 0.0, CGRectGetHeight(frame) * -1.0);
            self.firstView.frame = frame;
            self.firstView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                               UIViewAutoresizingFlexibleHeight |
                                               UIViewAutoresizingFlexibleBottomMargin);
        };
    }
    if (animated) {
        [UIView
         animateWithDuration:0.5
         delay:0.0
         options:UIViewAnimationOptionCurveEaseInOut
         animations:animations
         completion:nil];
    }
    else {
        animations();
    }
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // grid view
    self.gridView.rowHeight = 230.0;
    self.gridView.numberOfColumns = 3;
    self.gridView.verticalPadding = 30.0;
    self.gridView.horizontalPadding = 30.0;
    
    // colors
    self.gridView.backgroundColor = [UIColor clearColor];
    self.firstView.backgroundColor = [UIColor clearColor];
    self.emptyCellView.backgroundColor = [UIColor clearColor];
    
    // empty cell view
    UIImage *normal = [[UIImage imageNamed:@"GradientButton"] stretchableImageWithLeftCapWidth:11.0 topCapHeight:0.0];
    UIImage *highlighted = [[UIImage imageNamed:@"GradientButtonHighlighted"] stretchableImageWithLeftCapWidth:11.0 topCapHeight:0.0];
    NSMutableArray *buttons = [self.emptyCellButtons mutableCopy];
    [buttons addObject:self.meButton];
    [buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setBackgroundImage:normal forState:UIControlStateNormal];
        [obj setBackgroundImage:highlighted forState:UIControlStateHighlighted];
    }];
    
    // determine view placement
    [self adjustUserInterfaceForPatients:NO];
    NSString *host = [[HRAPIClient hosts] lastObject];
    [[HRAPIClient clientWithHost:host] patientFeed:nil];
    
}

- (void)viewDidUnload {
    self.emptyCellView = nil;
    self.emptyCellButtons = nil;
    [self viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.editing = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	return UIInterfaceOrientationIsLandscape(orientation);
}

#pragma mark - button actions

- (IBAction)meButtonPress:(id)sender {
    [self presentPopoverFromButton:sender withTitle:@"Add My Info" relationship:HRMPatientRelationshipMe completion:nil];
}

- (IBAction)spouseButtonPress:(id)sender {
    [self presentPopoverFromButton:sender withTitle:@"Add Spouse" relationship:HRMPatientRelationshipSpouse completion:nil]; 
}

- (IBAction)childButtonPress:(id)sender {
    [self presentPopoverFromButton:sender withTitle:@"Add Child" relationship:HRMPatientRelationshipChild completion:nil];
}

- (IBAction)familyMemberButtonPress:(id)sender {
    [self presentPopoverFromButton:sender withTitle:@"Add Family Member" relationship:HRMPatientRelationshipFamily completion:nil];
}

- (IBAction)viewInMainInterface:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    SVPanelViewController *panel = [storyboard instantiateInitialViewController];
    panel.mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"RootViewController"];
    panel.rightAccessoryViewController = [storyboard instantiateViewControllerWithIdentifier:@"AppletsConfigurationViewController"];
    panel.leftAccessoryViewController = [storyboard instantiateViewControllerWithIdentifier:@"PeoplePickerViewController"];
    [self presentViewController:panel animated:YES completion:nil];
}

- (void)deleteButtonPress:(UIButton *)button {
    
    // get patient
    HRPeopleSetupTileView *tile = ((HRPeopleSetupTileView *)button.superview);
    HRMPatient *patient = tile.patient;
    
    // prompt user to confirm
    GCAlertView *alert = [[GCAlertView alloc]
                          initWithTitle:@"Delete"
                          message:[NSString stringWithFormat:@"Are you sure you want to delete %@?", [patient compositeName]]];
    [alert addButtonWithTitle:@"Yes" block:^{
        NSManagedObjectContext *context = [patient managedObjectContext];
        [context deleteObject:patient];
        [context save:nil];
        [self.gridView reloadData];
        
    }];
    [alert addButtonWithTitle:@"No" block:nil];
    [alert setCancelButtonIndex:1];
    [alert show];
    
}

#pragma mark - grid view

- (NSUInteger)numberOfViewsInGridView:(HRGridTableView *)gridView {
    id<NSFetchedResultsSectionInfo> info = [[fetchedResultsController sections] objectAtIndex:0];
    return ([info numberOfObjects] + 1);
}

- (UIView *)gridView:(HRGridTableView *)gridView viewAtIndex:(NSUInteger)index {
    id<NSFetchedResultsSectionInfo> info = [[fetchedResultsController sections] objectAtIndex:0];
    if (index == [info numberOfObjects]) {
        return self.emptyCellView;
    }
    else {
        
        // get tile
        HRPeopleSetupTileView *tile = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
        
        // patient
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        HRMPatient *patient = [fetchedResultsController objectAtIndexPath:indexPath];
        tile.patient = patient;
        tile.nameLabel.text = [patient compositeName];
        tile.imageView.image = [patient patientImage];
        tile.statusLabel.text = patient.relationshipString;
        
        // shadow
        tile.layer.shadowColor = [[UIColor blackColor] CGColor];
        tile.layer.shadowOpacity = 0.35;
        tile.layer.shadowRadius = 5.0;
        tile.layer.shadowOffset = CGSizeMake(0.0, 3.0);
        tile.layer.shouldRasterize = YES;
        tile.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        tile.layer.cornerRadius = 20.0;
        
        // edit mode
        if (self.isEditing && ![tile viewWithTag:kDeleteButtonViewTag]) {
            
            // create button
            UIImage *normalImage = [UIImage imageNamed:@"interstitial_closebox"];
            UIImage *highlightedImage = [UIImage imageNamed:@"interstitial_closebox_down"];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundImage:normalImage forState:UIControlStateNormal];
            [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(deleteButtonPress:) forControlEvents:UIControlEventTouchUpInside];
            button.userInteractionEnabled = YES;
            button.adjustsImageWhenHighlighted = YES;
            button.tag = kDeleteButtonViewTag;
            
            // place button
            CGSize imageSize = normalImage.size;
            button.frame = CGRectMake(0.0,
                                      0.0,
                                      imageSize.width,
                                      imageSize.width);
            
            // add button
            [tile addSubview:button];
            
        }
        
        // return
        return tile;
        
    }
}

- (void)gridView:(HRGridTableView *)gridView didSelectViewAtIndex:(NSUInteger)index {
    id<NSFetchedResultsSectionInfo> info = [[fetchedResultsController sections] objectAtIndex:0];
    if (index < [info numberOfObjects]) {
        [HRPeoplePickerViewController setSelectedPatientIndex:index];
        [self showMainApplicationInterface];
    }
}

#pragma mark - fetched results controller

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"relationship = %d", HRMPatientRelationshipSpouse];
    NSUInteger count = [HRMPatient countInContext:managedObjectContext withPredicate:predicate];
    self.spouseButton.enabled = (count == 0);
    [self.gridView reloadData];
    [self adjustUserInterfaceForPatients:YES];
}

@end
