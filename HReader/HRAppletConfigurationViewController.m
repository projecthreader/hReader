//
//  HRAppletConfigurationViewController.m
//  HReader
//
//  Created by Caleb Davenport on 4/13/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRAppletConfigurationViewController.h"
#import "HRMPatient.h"
#import "HRPeoplePickerViewController.h"
#import "HRPanelViewController.h"

@implementation HRAppletConfigurationViewController {
    NSArray *_installedApplets;
    NSArray *_availableApplets;
    HRMPatient *_patient;
    BOOL _shouldReloadTableWhenContextSaves;
}

#pragma mark - class methods

+ (NSArray *)availableApplets {
    static dispatch_once_t token;
    static NSArray *applets = nil;
    dispatch_once(&token, ^{
        NSURL *URL = [[NSBundle mainBundle] URLForResource:@"HReaderApplets" withExtension:@"plist"];
        applets = [NSArray arrayWithContentsOfURL:URL];
#if DEBUG
        [applets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *class = [obj objectForKey:@"class_name"];
            NSAssert([obj objectForKey:@"identifier"], @"Applet payload is invalid.\n%@", obj);
            NSAssert(class, @"Applet \"%@\" has no declared class name.", [obj objectForKey:@"identifier"]);
            NSAssert(NSClassFromString(class), @"Class \"%@\" for applet \"%@\" does not exist.",
                     class,
                     [obj objectForKey:@"identifier"]);
        }];
#endif
    });
    return applets;
}

+ (NSDictionary *)appletWithIdentifier:(NSString *)identifier {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
    return [[[self availableApplets] filteredArrayUsingPredicate:predicate] lastObject];
}

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center
         addObserver:self
         selector:@selector(managedObjectContextDidSave)
         name:NSManagedObjectContextDidSaveNotification
         object:nil];
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
    [center
     removeObserver:self
     name:NSManagedObjectContextDidSaveNotification
     object:nil];
}

- (void)reloadApplets {
    
    // load system applets
    _availableApplets = [[HRAppletConfigurationViewController availableApplets] mutableCopy];
    
    // load patient applets
    NSArray *identifiers = _patient.applets;
    _installedApplets = [NSMutableArray arrayWithCapacity:[identifiers count]];
    [identifiers enumerateObjectsUsingBlock:^(NSString *identifier, NSUInteger index, BOOL *stop) {
        NSDictionary *applet = [HRAppletConfigurationViewController appletWithIdentifier:identifier];
        if (applet) {
            [(NSMutableArray *)_installedApplets addObject:applet];
            [(NSMutableArray *)_availableApplets removeObject:applet];
        }
    }];
    
    // sort system applets
    [(NSMutableArray *)_availableApplets sortUsingComparator:^NSComparisonResult(NSDictionary *one, NSDictionary *two) {
        return [[one objectForKey:@"display_name"] caseInsensitiveCompare:[two objectForKey:@"display_name"]];
    }];
    
}

- (void)managedObjectContextDidSave {
    [self reloadApplets];
    if (_shouldReloadTableWhenContextSaves) {
        [self.tableView reloadData];
    }
}

- (void)selectedPatientDidChange:(NSNotification *)notification {
    _patient = [[notification userInfo] objectForKey:HRSelectedPatientKey];
    [self reloadApplets];
    [self.tableView reloadData];
    self.tableView.contentOffset = CGPointZero;
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.editing = YES;
    _patient = [(id)self.panelViewController.leftAccessoryViewController selectedPatient];
    [self reloadApplets];
    [self.tableView reloadData];
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? [_installedApplets count] : [_availableApplets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = (indexPath.section == 0) ? _installedApplets : _availableApplets;
    NSString *identifier = ([array count]) ? @"BasicCell" : @"EmptyCell";
    NSDictionary *applet = ([array count]) ? [array objectAtIndex:indexPath.row] : nil;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.textLabel.text = (applet) ? [applet objectForKey:@"display_name"] : @"No Applets";
    cell.selectionStyle = (indexPath.section == 0) ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSMutableArray *array = [_patient.applets mutableCopy];
        NSDictionary *applet = [_availableApplets objectAtIndex:indexPath.row];
        [array addObject:[applet objectForKey:@"identifier"]];
        _patient.applets = array;
        _shouldReloadTableWhenContextSaves = NO;
        [[_patient managedObjectContext] save:nil];
        _shouldReloadTableWhenContextSaves = YES;
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[_installedApplets indexOfObject:applet] inSection:0];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
        [tableView insertRowsAtIndexPaths:@[ newIndexPath ] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (section == 0) ? @"\nInstalled Applets" : @"Available Applets";
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 0) ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleInsert;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // reload model
    NSDictionary *applet;
    NSMutableArray *array = [_patient.applets mutableCopy];
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        applet = [_availableApplets objectAtIndex:indexPath.row];
        [array addObject:[applet objectForKey:@"identifier"]];
    }
    else {
        applet = [_installedApplets objectAtIndex:indexPath.row];
        [array removeObject:[applet objectForKey:@"identifier"]];
    }
    _patient.applets = array;
    _shouldReloadTableWhenContextSaves = NO;
    [[_patient managedObjectContext] save:nil];
    _shouldReloadTableWhenContextSaves = YES;
    
    // update table view
    NSIndexPath *newIndexPath = nil;
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        newIndexPath = [NSIndexPath indexPathForRow:[_installedApplets indexOfObject:applet] inSection:0];
    }
    else {
        newIndexPath = [NSIndexPath indexPathForRow:[_availableApplets indexOfObject:applet] inSection:1];
    }
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
    [tableView insertRowsAtIndexPaths:@[ newIndexPath ] withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (proposedDestinationIndexPath.section == 0) { return proposedDestinationIndexPath; }
    else { return [NSIndexPath indexPathForRow:([tableView numberOfRowsInSection:0] - 1) inSection:0]; }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSMutableArray *array = [_patient.applets mutableCopy];
    NSString *identifier = [array objectAtIndex:sourceIndexPath.row];
    [array removeObjectAtIndex:sourceIndexPath.row];
    [array insertObject:identifier atIndex:destinationIndexPath.row];
    _patient.applets = array;
    [[_patient managedObjectContext] save:nil];
}

@end
