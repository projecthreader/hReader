//
//  HRAppletConfigurationViewController.m
//  HReader
//
//  Created by Caleb Davenport on 4/13/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRAppletConfigurationViewController.h"

#import "HRMPatient.h"

NSString * const HRAppletConfigurationDidChangeNotification = @"HRAppletConfigurationDidChange";

@interface HRAppletConfigurationViewController () {
@private
    NSArray * __strong installedApplets;
    NSArray * __strong availableApplets;
}

- (void)reloadApplets;

@end

@implementation HRAppletConfigurationViewController

@synthesize patient = _patient;

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(reloadApplets)
         name:NSManagedObjectContextDidSaveNotification
         object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:NSManagedObjectContextDidSaveNotification
     object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.editing = YES;
}

- (void)viewDidUnload {
    availableApplets = nil;
    installedApplets = nil;
    [super viewDidUnload];
}

- (void)setPatient:(HRMPatient *)patient {
    _patient = patient;
    [self reloadApplets];
    [self.tableView reloadData];
}

- (void)reloadApplets {
    
    // load system applets
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"HReaderApplets" withExtension:@"plist"];
    availableApplets = [[NSArray arrayWithContentsOfURL:URL] mutableCopy];
    
    // load patient applets
    NSArray *identifiers = self.patient.applets;
    installedApplets = [NSMutableArray arrayWithCapacity:[identifiers count]];
    [identifiers enumerateObjectsUsingBlock:^(NSString *identifier, NSUInteger index, BOOL *stop) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier like %@", identifier];
        NSDictionary *applet = [[availableApplets filteredArrayUsingPredicate:predicate] lastObject];
        [(NSMutableArray *)installedApplets addObject:applet];
        [(NSMutableArray *)availableApplets removeObject:applet];
    }];
    
    // sort system applets
    [(NSMutableArray *)availableApplets sortUsingComparator:^NSComparisonResult(NSDictionary *one, NSDictionary *two) {
        return [[one objectForKey:@"display_name"] caseInsensitiveCompare:[two objectForKey:@"display_name"]];
    }];
    
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? [installedApplets count] : [availableApplets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = (indexPath.section == 0) ? installedApplets : availableApplets;
    NSString *identifier = ([array count]) ? @"BasicCell" : @"EmptyCell";
    NSDictionary *applet = ([array count]) ? [array objectAtIndex:indexPath.row] : nil;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.textLabel.text = (applet) ? [applet objectForKey:@"display_name"] : @"No Applets";
    cell.selectionStyle = (indexPath.section == 0) ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSMutableArray *array = [self.patient.applets mutableCopy];
        NSDictionary *applet = [availableApplets objectAtIndex:indexPath.row];
        [array addObject:[applet objectForKey:@"identifier"]];
        self.patient.applets = array;
        [[self.patient managedObjectContext] save:nil];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[installedApplets indexOfObject:applet] inSection:0];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    NSMutableArray *array = [self.patient.applets mutableCopy];
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        applet = [availableApplets objectAtIndex:indexPath.row];
        [array addObject:[applet objectForKey:@"identifier"]];
    }
    else {
        applet = [installedApplets objectAtIndex:indexPath.row];
        [array removeObject:[applet objectForKey:@"identifier"]];
    }
    self.patient.applets = array;
    [[self.patient managedObjectContext] save:nil];
    
    // update table view
    NSIndexPath *newIndexPath = nil;
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        newIndexPath = [NSIndexPath indexPathForRow:[installedApplets indexOfObject:applet] inSection:0];
    }
    else {
        newIndexPath = [NSIndexPath indexPathForRow:[availableApplets indexOfObject:applet] inSection:1];
    }
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (proposedDestinationIndexPath.section == 0) {
        return proposedDestinationIndexPath;
    }
    else {
        return [NSIndexPath indexPathForRow:([tableView numberOfRowsInSection:0] - 1) inSection:0];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSMutableArray *array = [self.patient.applets mutableCopy];
    NSString *identifier = [array objectAtIndex:sourceIndexPath.row];
    [array removeObjectAtIndex:sourceIndexPath.row];
    [array insertObject:identifier atIndex:destinationIndexPath.row];
    self.patient.applets = array;
    [[self.patient managedObjectContext] save:nil];
}

@end
