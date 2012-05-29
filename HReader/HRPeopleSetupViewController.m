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

#import "HRMPatient.h"

@interface HRPeopleSetupViewController () {
@private
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    UINib *nib;
}

@end

@implementation HRPeopleSetupViewController

@synthesize gridView = _gridView;
@synthesize emptyCellView = _emptyCellView;
@synthesize spouseButton = _spouseButton;
@synthesize emptyCellButtons = _emptyCellButtons;

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        nib = [UINib nibWithNibName:@"HRPeopleSetupTileView" bundle:nil];
        managedObjectContext = [HRAppDelegate managedObjectContext];
        NSFetchRequest *request = [HRMPatient fetchRequestInContext:managedObjectContext];
        NSArray *descriptors = [NSArray arrayWithObjects:
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
    [self.emptyCellButtons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setBackgroundImage:normal forState:UIControlStateNormal];
        [obj setBackgroundImage:highlighted forState:UIControlStateHighlighted];
    }];
    
}

- (void)viewDidUnload {
    self.emptyCellView = nil;
    [self viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	return UIInterfaceOrientationIsLandscape(orientation);
}

#pragma mark - button actions

- (IBAction)spouseButtonPress:(id)sender {
    
}

- (IBAction)childButtonPress:(id)sender {

}

- (IBAction)familyMemberButtonPress:(id)sender {
    
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
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        HRMPatient *patient = [fetchedResultsController objectAtIndexPath:indexPath];
        NSLog(@"%@", patient);
    }
}

#pragma mark - fetched results controller

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"relationship == %d", HRMPatientRelationshipSpouse];
    NSUInteger count = [HRMPatient countInContext:managedObjectContext withPredicate:predicate];
    self.spouseButton.enabled = (count == 0);
    [self.gridView reloadData];
}

@end
