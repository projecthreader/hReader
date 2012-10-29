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
#import "HRPanelViewController.h"
#import "HRMPatient.h"

#import "CMDBlocksKit.h"

#define kDeleteButtonViewTag 100

@implementation HRPeopleSetupViewController {
@private
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    UIPopoverController *_popoverController;
    UINib *nib;
}

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        nib = [UINib nibWithNibName:@"HRPeopleSetupTileView" bundle:nil];
        managedObjectContext = [HRAppDelegate managedObjectContext];
        NSFetchRequest *request = [HRMPatient fetchRequestInContext:managedObjectContext];
        NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
        [request setSortDescriptors:descriptors];
        fetchedResultsController = [[NSFetchedResultsController alloc]
                                    initWithFetchRequest:request
                                    managedObjectContext:managedObjectContext
                                    sectionNameKeyPath:nil
                                    cacheName:nil];
        fetchedResultsController.delegate = self;
        [fetchedResultsController performFetch:nil];
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(applicationDidEnterBackground)
         name:UIApplicationDidEnterBackgroundNotification
         object:nil];
    }
    return self;
}

- (void)dealloc {
    fetchedResultsController.delegate = nil;
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIApplicationDidEnterBackgroundNotification
     object:nil];
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
        [client
         JSONForPatientWithIdentifier:identifier
         startBlock:nil
         finishBlock:^(NSDictionary *payload) {
             if (payload) {
                 NSManagedObjectContext *context = [HRAppDelegate managedObjectContext];
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
    HRPanelViewController *panel = [storyboard instantiateInitialViewController];
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
    if ([HRMPatient countInContext:[HRAppDelegate managedObjectContext] predicate:predicate] == 0) {
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

- (void)applicationDidEnterBackground {
    [_popoverController dismissPopoverAnimated:NO];
    _popoverController = nil;
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.editing = NO;
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
    [self showMainApplicationInterface];
}

- (void)deleteButtonPress:(UIButton *)button {
    
    // get patient
    HRPeopleSetupTileView *tile = ((HRPeopleSetupTileView *)button.superview);
    HRMPatient *patient = tile.patient;
    
    // prompt user to confirm
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete %@?", [patient compositeName]];
    CMDAlertView *alert = [[CMDAlertView alloc] initWithTitle:@"Delete" message:message];
    [alert addButtonWithTitle:@"Cancel" block:nil];
    [alert addButtonWithTitle:@"Delete" block:^{
        NSManagedObjectContext *context = [patient managedObjectContext];
        [context deleteObject:patient];
        [context save:nil];
        [self.gridView reloadData];
        
    }];
    [alert setCancelButtonIndex:0];
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
        tile.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        tile.layer.shadowOpacity = 0.1;
        tile.layer.shadowRadius = 5.0;
        tile.layer.shouldRasterize = YES;
        tile.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        tile.layer.cornerRadius = 20.0;
        tile.layer.borderColor = [[UIColor colorWithWhite:0.79 alpha:1.0] CGColor];
        tile.layer.borderWidth = 1.0;
        
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
    if (index < [[fetchedResultsController fetchedObjects] count]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        id object = [fetchedResultsController objectAtIndexPath:indexPath];
        [HRPeoplePickerViewController setSelectedPatient:object];
        [self showMainApplicationInterface];
    }
}

#pragma mark - fetched results controller

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"relationship = %d", HRMPatientRelationshipSpouse];
    NSUInteger count = [HRMPatient countInContext:managedObjectContext predicate:predicate];
    self.spouseButton.enabled = (count == 0);
    [self.gridView reloadData];
    [self adjustUserInterfaceForPatients:YES];
}

@end
