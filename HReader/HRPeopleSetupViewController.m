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

@end

@implementation HRPeopleSetupViewController

@synthesize gridView = _gridView;
@synthesize emptyCellView = _emptyCellView;
@synthesize spouseButton = _spouseButton;
@synthesize emptyCellButtons = _emptyCellButtons;
@synthesize meButton = _meButton;
@synthesize imageView = _imageView;

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
    NSString *host = [[HRAPIClient accounts] lastObject];
    HRAPIClient *client = [HRAPIClient clientWithHost:host];
    
    // create controller
    HRPeopleFeedViewController *controller = [[HRPeopleFeedViewController alloc] initWithHost:host];
    controller.title = title;
    controller.didFinishBlock = ^(NSString *identifier) {
        [client JSONForPatientWithIdentifier:identifier completion:^(NSDictionary *payload) {
            NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
            [context setPersistentStoreCoordinator:[HRAppDelegate persistentStoreCoordinator]];
            HRMPatient *patient = [HRMPatient instanceInContext:context];
            [patient populateWithContentsOfDictionary:payload];
            patient.serverID = identifier;
            patient.relationship = [NSNumber numberWithShort:relationship];
            [context save:nil];
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

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // grid view
    self.gridView.rowHeight = 230.0;
    self.gridView.numberOfColumns = 3;
    self.gridView.verticalPadding = 30.0;
    self.gridView.horizontalPadding = 30.0;
    
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"relationship = %d", HRMPatientRelationshipMe];
    if ([HRMPatient countInContext:[HRAppDelegate managedObjectContext] withPredicate:predicate] == 0) {
        CGRect frame = self.view.bounds;
        frame = CGRectOffset(frame, 0.0, CGRectGetHeight(frame));
        self.gridView.frame = frame;
        self.gridView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    }
    else {
        self.gridView.frame = self.view.bounds;
        self.gridView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        self.imageView.hidden = YES;
        self.meButton.hidden = YES;
    }
    
    // initiate initial patient load
    NSString *host = [[HRAPIClient accounts] lastObject];
    [[HRAPIClient clientWithHost:host] patientFeed:nil];
    
}

- (void)viewDidUnload {
    self.emptyCellView = nil;
    self.emptyCellButtons = nil;
    [self viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	return UIInterfaceOrientationIsLandscape(orientation);
}

#pragma mark - button actions

- (IBAction)meButtonPress:(id)sender {
    [self presentPopoverFromButton:sender withTitle:@"Add My Info" relationship:HRMPatientRelationshipMe completion:^{
        [UIView
         animateWithDuration:0.5
         delay:0.5
         options:UIViewAnimationOptionCurveEaseInOut
         animations:^{
             CGRect frame = self.imageView.frame;
             frame = CGRectOffset(frame, 0.0, CGRectGetHeight(self.view.bounds) * -1.0);
             self.imageView.frame = frame;
             frame = self.meButton.frame;
             frame = CGRectOffset(frame, 0.0, CGRectGetHeight(self.view.bounds) * -1.0);
             self.meButton.frame = frame;
             self.gridView.frame = self.view.bounds;
         }
         completion:^(BOOL finished) {
             self.gridView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
         }];
    }];
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
        
        // return
        return tile;
        
    }
}

- (void)gridView:(HRGridTableView *)gridView didSelectViewAtIndex:(NSUInteger)index {
    id<NSFetchedResultsSectionInfo> info = [[fetchedResultsController sections] objectAtIndex:0];
    if (index < [info numberOfObjects]) {
        [HRPeoplePickerViewController setSelectedPatientIndex:index];
        [self showMainApplicationInterface];
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
//        HRMPatient *patient = [fetchedResultsController objectAtIndexPath:indexPath];
//        NSLog(@"%@", patient);
    }
}

#pragma mark - fetched results controller

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"relationship = %d", HRMPatientRelationshipSpouse];
    NSUInteger count = [HRMPatient countInContext:managedObjectContext withPredicate:predicate];
    self.spouseButton.enabled = (count == 0);
    [self.gridView reloadData];
}

@end
