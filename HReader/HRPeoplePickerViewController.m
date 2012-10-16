//
//  HRPeoplePickerViewController.m
//  HReader
//
//  Created by Caleb Davenport on 4/18/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRPeoplePickerViewController_private.h"
#import "HRAppDelegate.h"
#import "HRMPatient.h"
#import "HRPanelViewController.h"

NSString * const HRSelectedPatientDidChangeNotification = @"HRSelectedPatientDidChange";
NSString * const HRSelectedPatientKey = @"HRSelectedPatient";
static NSString * const HRSelectedPatientURIKey = @"HRSelectedPatientURI";

@implementation HRPeoplePickerViewController {
    
    // selected patient
    HRMPatient *_selectedPatient;
    
    // patient list
    NSManagedObjectContext *_managedObjectContext;
    NSFetchedResultsController *_fetchedResultsController;
    BOOL _shouldIgnoreUpdatesFromFetchedResultsController;
    
    // search
    NSArray *searchResults;
    
}

#pragma mark - class methods

+ (void)setSelectedPatient:(HRMPatient *)patient {
    
    // assert
    NSAssert([NSThread isMainThread], @"This method must be called on the main thread.");
    NSAssert(patient, @"Patient must not be nil.");
    
    // save to user defaults
    NSString *string = [[[patient objectID] URIRepresentation] absoluteString];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:string forKey:HRSelectedPatientURIKey];
    [settings synchronize];
    
    // post notification
    [[NSNotificationCenter defaultCenter]
     postNotificationName:HRSelectedPatientDidChangeNotification
     object:nil
     userInfo:@{
         HRSelectedPatientKey : patient
     }];

}

+ (HRMPatient *)selectedPatient {
    
    // assert
    NSAssert([NSThread isMainThread], @"This method must be called on the main thread.");
    
    // grab context
    NSManagedObjectContext *context = [HRAppDelegate managedObjectContext];
    
    // grab object id
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:HRSelectedPatientURIKey];
    NSURL *URL = [NSURL URLWithString:string];
    NSPersistentStoreCoordinator *coordinator = [context persistentStoreCoordinator];
    NSManagedObjectID *objectID = [coordinator managedObjectIDForURIRepresentation:URL];
    
    // grab object
    id patient = nil;
    if (objectID) { patient = [context existingObjectWithID:objectID error:nil]; }
    if (patient == nil) {
        NSFetchRequest *request = [HRPeoplePickerViewController allPatientsFetchRequestInContext:context];
        patient = [[context executeFetchRequest:request error:nil] objectAtIndex:0];
    }
    return patient;
}

+ (NSFetchRequest *)allPatientsFetchRequestInContext:(NSManagedObjectContext *)context {
    static NSFetchRequest *request = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *descriptors = @[
            [NSSortDescriptor sortDescriptorWithKey:@"displayOrder" ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]
        ];
        request = [HRMPatient fetchRequestInContext:context];
        [request setSortDescriptors:descriptors];
    });
    return request;
}

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        
        // load data from core data
        _managedObjectContext = [HRAppDelegate managedObjectContext];
        NSFetchRequest *request = [HRPeoplePickerViewController allPatientsFetchRequestInContext:_managedObjectContext];
        _fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:request
                                     managedObjectContext:_managedObjectContext
                                     sectionNameKeyPath:nil
                                     cacheName:nil];
        _fetchedResultsController.delegate = self;
        NSError *error = nil;
        BOOL fetch = [_fetchedResultsController performFetch:&error];
        NSAssert(fetch, @"Unable to fetch patients\n%@", error);
        
        // cache selected patient
        _selectedPatient = [HRPeoplePickerViewController selectedPatient];
        
        // notifications
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center
         addObserver:self
         selector:@selector(selectedPatientDidChange:)
         name:HRSelectedPatientDidChangeNotification
         object:nil];
        
    }
    return self;
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center
     removeObserver:self
     name:HRSelectedPatientDidChangeNotification
     object:nil];
}

- (void)selectedPatientDidChange:(NSNotification *)notification {
    _selectedPatient = [[notification userInfo] objectForKey:HRSelectedPatientKey];
    [self updateTableViewSelection];
}

- (IBAction)showManageFamilyInterface:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (HRMPatient *)selectedPatient {
    return _selectedPatient;
}

- (void)selectNextPatient {
    NSIndexPath *indexPath = [_fetchedResultsController indexPathForObject:_selectedPatient];
    NSInteger newIndex = indexPath.row + 1;
    if (newIndex >= (NSInteger)[[_fetchedResultsController fetchedObjects] count]) {
        newIndex = 0;
    }
    indexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
    _selectedPatient = [_fetchedResultsController objectAtIndexPath:indexPath];
    [HRPeoplePickerViewController setSelectedPatient:_selectedPatient];
    [self updateTableViewSelection];
}

- (void)selectPreviousPatient {
    NSIndexPath *indexPath = [_fetchedResultsController indexPathForObject:_selectedPatient];
    NSInteger newIndex = indexPath.row - 1;
    if (newIndex < 0) {
        newIndex = (NSInteger)([[_fetchedResultsController fetchedObjects] count] - 1);
    }
    indexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
    _selectedPatient = [_fetchedResultsController objectAtIndexPath:indexPath];
    [HRPeoplePickerViewController setSelectedPatient:_selectedPatient];
    [self updateTableViewSelection];
}

- (void)updateTableViewSelection {
    NSIndexPath *indexPath = [_fetchedResultsController indexPathForObject:_selectedPatient];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _shouldIgnoreUpdatesFromFetchedResultsController = NO;
    self.tableView.editing = YES;
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    
    // prepare variables
    static NSArray *descriptors = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        descriptors = @[
            [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]
        ];
    });
    
    // perform search
    NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[
                              [NSPredicate predicateWithFormat:@"firstName contains[cd] %@", searchText],
                              [NSPredicate predicateWithFormat:@"lastName contains[cd] %@", searchText]
                              ]];
    searchResults = [HRMPatient
                     allInContext:_managedObjectContext
                     predicate:predicate
                     sortDescriptors:descriptors];
    
}

#pragma mark - table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        id<NSFetchedResultsSectionInfo> info = [[_fetchedResultsController sections] objectAtIndex:section];
        return [info numberOfObjects];
    }
    else { return [searchResults count]; }
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
    if (tableView == self.tableView) { patient = [_fetchedResultsController objectAtIndexPath:indexPath]; }
    else { patient = [searchResults objectAtIndex:indexPath.row]; }
    cell.textLabel.text = [patient compositeName];
    cell.imageView.image = [patient patientImage];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    if (tableView == self.tableView) { _selectedPatient = [_fetchedResultsController objectAtIndexPath:indexPath]; }
    else { _selectedPatient = [searchResults objectAtIndex:indexPath.row]; }
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.15 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [HRPeoplePickerViewController setSelectedPatient:_selectedPatient];
        [self.panelViewController showMainViewController:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
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
    NSMutableArray *objects  = [_fetchedResultsController.fetchedObjects mutableCopy];
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
    
    // save
    _shouldIgnoreUpdatesFromFetchedResultsController = YES;
    [_managedObjectContext save:nil];
    _shouldIgnoreUpdatesFromFetchedResultsController = NO;
    
}

#pragma mark - fetched results controller

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (_shouldIgnoreUpdatesFromFetchedResultsController) { return; }
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (_shouldIgnoreUpdatesFromFetchedResultsController) { return; }
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)object atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (_shouldIgnoreUpdatesFromFetchedResultsController) { return; }
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
    if (_shouldIgnoreUpdatesFromFetchedResultsController) { return; }
    UITableView *tableView = self.tableView;
    if (type == NSFetchedResultsChangeInsert) {
        [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeDelete) {
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
