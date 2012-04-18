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

@interface HRPeoplePickerViewController () {
@private
    NSFetchedResultsController * __strong controller;
    NSManagedObjectContext * __strong context;
    NSArray * __strong searchResults;
    NSArray * __strong sortDescriptors;
}

@end

@implementation HRPeoplePickerViewController

@synthesize tableView = __tableView;

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // load data
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

- (void)viewDidUnload {
    controller = nil;
    context = nil;
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchDisplayController setActive:NO animated:animated];
}

#pragma mark - search controller

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    tableView.rowHeight = self.tableView.rowHeight;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if ([searchResults count]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performSearch) object:nil];
        [self performSelector:@selector(performSearch) withObject:nil afterDelay:0.25];
        return NO;
    }
    else {
        [self performSearch];
        return YES;
    }
}

#pragma mark - perform search

- (void)performSearch {
    NSString *text = self.searchDisplayController.searchBar.text;
    NSPredicate *predicateOne = [NSPredicate predicateWithFormat:@"firstName contains[cd] %@", text];
    NSPredicate *predicateTwo = [NSPredicate predicateWithFormat:@"lastName contains[cd] %@", text];
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

#pragma mark - fetched results controller

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

@end
