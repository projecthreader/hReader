//
//  HRPeoplePickerViewController.m
//  HReader
//
//  Created by Caleb Davenport on 4/18/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRPeoplePickerViewController.h"
#import "HRAppDelegate.h"

#import "HRMPatient.h"

#import "SVPanelViewController.h"

NSString * const HRPatientDidChangeNotification = @"HRPatientDidChange";
static NSString * const HRSelectedPatientIndexKey = @"HRSelectedPatientIndex";

@interface HRPeoplePickerViewController () {
@private
    
    // support showing the main patient list
    NSManagedObjectContext * __strong managedObjectContext;
    NSFetchedResultsController * __strong fetchedResultsController;
    NSInteger selectedPatientIndex;
    BOOL shouldIgnoreUpdatesFromFetchedResultsController;
    
    // support people search
    NSArray * __strong searchResults;
    NSArray * __strong sortDescriptors;
    
}

- (void)updateTableViewSelection;
- (void)persistSelectedPatientIndex;

@end

@implementation HRPeoplePickerViewController

@synthesize tableView = _tableView;
@synthesize toolbar = _toolbar;

#pragma mark - public methods

- (HRMPatient *)selectedPatient {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedPatientIndex inSection:0];
    NSLog(@"%@", [fetchedResultsController fetchedObjects]);
    id object = nil;
    @try { [fetchedResultsController objectAtIndexPath:indexPath]; }
    @catch (NSException *exception) {}
    @finally {}
    return object;
}

- (void)selectNextPatient {
    selectedPatientIndex++;
    if (selectedPatientIndex >= (NSInteger)[[fetchedResultsController fetchedObjects] count]) {
        selectedPatientIndex = 0;
    }
    [self updateTableViewSelection];
    [self persistSelectedPatientIndex];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:HRPatientDidChangeNotification
     object:self];
}

- (void)selectPreviousPatient {
    selectedPatientIndex--;
    if (selectedPatientIndex <= 0) {
        selectedPatientIndex = (NSInteger)([[fetchedResultsController fetchedObjects] count] - 1);
    }
    [self updateTableViewSelection];
    [self persistSelectedPatientIndex];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:HRPatientDidChangeNotification
     object:self];
}

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        
        // load data from core data
        managedObjectContext = [HRAppDelegate managedObjectContext];
        sortDescriptors = [NSArray arrayWithObjects:
                           [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES],
                           [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES],
                           nil];
        NSMutableArray *descriptors = [sortDescriptors mutableCopy];
        [descriptors insertObject:[NSSortDescriptor sortDescriptorWithKey:@"displayOrder" ascending:YES] atIndex:0];
        NSFetchRequest *request = [HRMPatient fetchRequestInContext:managedObjectContext];
        [request setSortDescriptors:descriptors];
        fetchedResultsController = [[NSFetchedResultsController alloc]
                                    initWithFetchRequest:request
                                    managedObjectContext:managedObjectContext
                                    sectionNameKeyPath:nil
                                    cacheName:nil];
        fetchedResultsController.delegate = self;
        NSError *error = nil;
        BOOL fetch = [fetchedResultsController performFetch:&error];
        NSAssert(fetch, @"Unable to fetch patients\n%@", error);
        
        // selected index
        selectedPatientIndex = MIN([[NSUserDefaults standardUserDefaults] integerForKey:HRSelectedPatientIndexKey],
                                   (NSInteger)[[fetchedResultsController fetchedObjects] count]);
        
    }
    return self;
}

- (void)updateTableViewSelection {
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedPatientIndex inSection:0];
//    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)persistSelectedPatientIndex {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setInteger:selectedPatientIndex forKey:HRSelectedPatientIndexKey];
    [settings synchronize];
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    shouldIgnoreUpdatesFromFetchedResultsController = NO;
    self.tableView.editing = YES;
    [self.tableView reloadData];
    [self updateTableViewSelection];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchDisplayController setActive:NO animated:animated];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

#pragma mark - search controller

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    tableView.rowHeight = self.tableView.rowHeight;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSPredicate *predicateOne = [NSPredicate predicateWithFormat:@"firstName contains[cd] %@", searchText];
    NSPredicate *predicateTwo = [NSPredicate predicateWithFormat:@"lastName contains[cd] %@", searchText];
    NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:
                              [NSArray arrayWithObjects:predicateOne, predicateTwo, nil]];
    searchResults = [HRMPatient
                     allInContext:managedObjectContext
                     withPredicate:predicate
                     sortDescriptors:sortDescriptors];
}

#pragma mark - table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        id<NSFetchedResultsSectionInfo> info = [[fetchedResultsController sections] objectAtIndex:section];
        return [info numberOfObjects];
    }
    else {
        return [searchResults count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.imageView.layer.cornerRadius = 5.0;
        cell.imageView.layer.masksToBounds = YES;
    }
    HRMPatient *patient = nil;
    if (tableView == self.tableView) { patient = [fetchedResultsController objectAtIndexPath:indexPath]; }
    else { patient = [searchResults objectAtIndex:indexPath.row]; }
    cell.textLabel.text = [patient compositeName];
    cell.imageView.image = [patient patientImage];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        selectedPatientIndex = indexPath.row;
    }
    else {
        HRMPatient *patient = [searchResults objectAtIndex:indexPath.row];
        selectedPatientIndex = [fetchedResultsController indexPathForObject:patient].row;
        [self updateTableViewSelection];
    }
    double delay = 0.15;
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [[NSNotificationCenter defaultCenter]
         postNotificationName:HRPatientDidChangeNotification
         object:self];
        [self.panelViewController hideAccessoryViewControllers:YES];
    });
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    // gather patients and other variables
    NSMutableArray *objects  = [fetchedResultsController.fetchedObjects mutableCopy];
    NSInteger max = MAX(fromIndexPath.row, toIndexPath.row);
    
    // perform reorder
    id object = [objects objectAtIndex:fromIndexPath.row];
    [objects removeObjectAtIndex:fromIndexPath.row];
    [objects insertObject:object atIndex:toIndexPath.row];
    
    // set display order up to the highest effected row
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *number = [NSNumber numberWithLong:(long)idx];
        [obj setDisplayOrder:number];
        if ((NSInteger)idx >= max) { *stop = YES; }
    }];
    
    // update selected index
    if (fromIndexPath.row == selectedPatientIndex) { selectedPatientIndex = toIndexPath.row; }
    else if (max >= selectedPatientIndex) {
        if (fromIndexPath.row <= selectedPatientIndex) { selectedPatientIndex--; }
        else if (toIndexPath.row <= selectedPatientIndex) { selectedPatientIndex++; }
    }
    [self persistSelectedPatientIndex];
    
    // save
    shouldIgnoreUpdatesFromFetchedResultsController = YES;
    [managedObjectContext save:nil];
    shouldIgnoreUpdatesFromFetchedResultsController = NO;
    
}

#pragma mark - fetched results controller

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (shouldIgnoreUpdatesFromFetchedResultsController) { return; }
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (shouldIgnoreUpdatesFromFetchedResultsController) { return; }
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)object atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (shouldIgnoreUpdatesFromFetchedResultsController) { return; }
	UITableView *tableView = self.tableView;
    if (type == NSFetchedResultsChangeInsert) {
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeDelete) {
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeUpdate) {
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if (type == NSFetchedResultsChangeMove) {
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    if (shouldIgnoreUpdatesFromFetchedResultsController) { return; }
    UITableView *tableView = self.tableView;
    if (type == NSFetchedResultsChangeInsert) {
        [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeDelete) {
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
