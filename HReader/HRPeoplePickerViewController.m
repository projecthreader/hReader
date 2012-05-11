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
static NSString * const HRPatientOrderArrayKey = @"HRPatientOrderArray";
static NSString * const HRSelectedPatientIndexKey = @"HRSelectedPatientIndex";

@interface HRPeoplePickerViewController () {
@private
    NSManagedObjectContext * __strong context;
    NSMutableArray * __strong patients;
    NSArray * __strong searchResults;
    NSArray * __strong sortDescriptors;
    NSInteger selectedPatientIndex;
}

- (void)updateTableViewSelection;
- (void)persistSelectedPatientIndex;
- (void)persistPatientOrder;

@end

@implementation HRPeoplePickerViewController

@synthesize tableView = __tableView;
@synthesize toolbar = __toolbar;

#pragma mark - public methods

- (HRMPatient *)selectedPatient {
    return [patients objectAtIndex:selectedPatientIndex];
}

- (void)selectNextPatient {
    selectedPatientIndex++;
    if (selectedPatientIndex == (NSInteger)[patients count]) { selectedPatientIndex = 0; }
    [self updateTableViewSelection];
    [self persistSelectedPatientIndex];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:HRPatientDidChangeNotification
     object:self];
}

- (void)selectPreviousPatient {
    if (selectedPatientIndex == 0) { selectedPatientIndex = [patients count] - 1; }
    else { selectedPatientIndex--; }
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
        
        // create context
        context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [context setParentContext:[HRAppDelegate managedObjectContext]];
        
        // load array
        NSArray *objectIDStrings = [[NSUserDefaults standardUserDefaults] arrayForKey:HRPatientOrderArrayKey];
        if (objectIDStrings) {
            patients = [[NSMutableArray alloc] initWithCapacity:[objectIDStrings count]];
            [objectIDStrings enumerateObjectsUsingBlock:^(NSString *mongoID, NSUInteger index, BOOL *stop) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mongoID == %@", mongoID];
                HRMPatient *patient = [[HRMPatient allInContext:context withPredicate:predicate] lastObject];
                [patients addObject:patient];
            }];
        }
        else {
            NSFetchRequest *request = [HRMPatient fetchRequestInContext:context];
            NSString *sort = [NSSortDescriptor sortDescriptorWithKey:@"dateOfBirth" ascending:YES];
            sortDescriptors = [NSArray arrayWithObjects:sort, nil];
            [request setSortDescriptors:sortDescriptors];
            NSError *error = nil;            
            patients = [[context executeFetchRequest:request error:&error] mutableCopy];
            NSAssert(patients != nil, @"Unable to fetch patients\n%@", error);

            [self persistPatientOrder];
        }
        
        // selected index
        selectedPatientIndex = [[NSUserDefaults standardUserDefaults] integerForKey:HRSelectedPatientIndexKey];
        if (selectedPatientIndex >= (NSInteger)[patients count]) { selectedPatientIndex = 0; }
        
        // notifications
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(managedObjectDidSave:)
         name:NSManagedObjectContextDidSaveNotification
         object:context];
        
    }
    return self;
}

- (void)managedObjectDidSave:(NSNotification *)notification {
    
}

- (void)updateTableViewSelection {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedPatientIndex inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)persistSelectedPatientIndex {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setInteger:selectedPatientIndex forKey:HRSelectedPatientIndexKey];
    [settings synchronize];
}

- (void)persistPatientOrder {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSArray *objectIDStrings = [patients valueForKey:@"mongoID"];
    [settings setObject:objectIDStrings forKey:HRPatientOrderArrayKey];
    [settings synchronize];
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
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
    searchResults = [HRMPatient allInContext:context withPredicate:predicate sortDescriptors:sortDescriptors];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

#pragma mark - table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (tableView == self.tableView) ? [patients count] : [searchResults count];
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
    if (tableView == self.tableView) {
        patient = [patients objectAtIndex:indexPath.row];
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
        selectedPatientIndex = [patients indexOfObject:patient];
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
    id object = [patients objectAtIndex:fromIndexPath.row];
    [patients removeObjectAtIndex:fromIndexPath.row];
    [patients insertObject:object atIndex:toIndexPath.row];
    if (selectedPatientIndex == fromIndexPath.row) {
        selectedPatientIndex = toIndexPath.row;
        [self persistSelectedPatientIndex];
    }
    [self persistPatientOrder];
}

@end
