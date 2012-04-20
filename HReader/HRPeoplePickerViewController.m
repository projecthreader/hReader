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

@interface HRPeoplePickerViewController () {
@private
    NSFetchedResultsController * __strong controller;
    NSManagedObjectContext * __strong context;
    NSArray * __strong searchResults;
    NSArray * __strong sortDescriptors;
    NSUInteger selectedPatientIndex;
}

- (void)updateTableViewSelection;

@end

@implementation HRPeoplePickerViewController

@synthesize tableView = __tableView;

#pragma mark - public methods

- (HRMPatient *)selectedPatient {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedPatientIndex inSection:0];
    return [controller objectAtIndexPath:indexPath];
}

- (void)selectNextPatient {
    NSUInteger oldIndex = selectedPatientIndex;
    id<NSFetchedResultsSectionInfo> info = [[controller sections] objectAtIndex:0];
    selectedPatientIndex = MIN(selectedPatientIndex + 1, [info numberOfObjects] - 1);
    [self updateTableViewSelection];
    if (selectedPatientIndex != oldIndex) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:HRPatientDidChangeNotification
         object:self];
    }
}

- (void)selectPreviousPatient {
    NSUInteger oldIndex = selectedPatientIndex;
    if (selectedPatientIndex > 0) { selectedPatientIndex--; }
    [self updateTableViewSelection];
    if (selectedPatientIndex != oldIndex) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:HRPatientDidChangeNotification
         object:self];
    }
}

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        selectedPatientIndex = 0;
        context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [context setParentContext:[HRAppDelegate managedObjectContext]];
        NSFetchRequest *request = [HRMPatient fetchRequestInContext:context];
        NSSortDescriptor *sortOne = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
        NSSortDescriptor *sortTwo = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
        sortDescriptors = [NSArray arrayWithObjects:sortOne, sortTwo, nil];
        [request setSortDescriptors:sortDescriptors];
        controller = [[NSFetchedResultsController alloc]
                      initWithFetchRequest:request
                      managedObjectContext:context
                      sectionNameKeyPath:nil
                      cacheName:nil];
        controller.delegate = self;
        NSError *error = nil;
        BOOL fetch = [controller performFetch:&error];
        NSAssert(fetch, @"Unable to fetch patients\n%@", error);
    }
    return self;
}

- (void)updateTableViewSelection {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedPatientIndex inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView reloadData];
    [self updateTableViewSelection];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchDisplayController setActive:NO animated:animated];
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
    searchResults = [HRMPatient allInContext:context withPredicate:predicate sortDescriptors:sortDescriptors];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

#pragma mark - table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        id<NSFetchedResultsSectionInfo> info = [[controller sections] objectAtIndex:section];
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
//        cell.imageView.layer.shadowColor = [[UIColor blackColor] CGColor];
//        cell.imageView.layer.shadowRadius = 5.0;
//        cell.imageView.layer.shadowOpacity = 0.5;
        cell.imageView.layer.cornerRadius = 5.0;
        cell.imageView.layer.masksToBounds = YES;
    }
    HRMPatient *patient = nil;
    if (tableView == self.tableView) {
        patient = [controller objectAtIndexPath:indexPath];
    }
    else {
        patient = [searchResults objectAtIndex:indexPath.row];
    }
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
        NSIndexPath *patientIndexPath = [controller indexPathForObject:patient];
        selectedPatientIndex = patientIndexPath.row;
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

#pragma mark - fetched results controller

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

@end
