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
    NSArray * __strong __availableApplets;
    NSArray * __strong __installedApplets;
}

- (void)reloadApplets;

@end

@implementation HRAppletConfigurationViewController

@synthesize patient = __patient;

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.patient = [HRMPatient selectedPatient];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.editing = YES;
    [self reloadApplets];
}

- (void)viewDidUnload {
    __availableApplets = nil;
    [super viewDidUnload];
}

- (void)setPatient:(HRMPatient *)patient {
    if (!__patient || !patient) {
        __patient = patient;
    }
}

- (void)reloadApplets {
    
    // load system applets
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"HReaderApplets" withExtension:@"plist"];
    __availableApplets = [[NSArray arrayWithContentsOfURL:URL] mutableCopy];
    
    // load patient applets
    NSArray *identifiers = self.patient.applets;
    __installedApplets = [NSMutableArray arrayWithCapacity:[identifiers count]];
    [identifiers enumerateObjectsUsingBlock:^(NSString *identifier, NSUInteger index, BOOL *stop) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier like %@", identifier];
        NSDictionary *applet = [[__availableApplets filteredArrayUsingPredicate:predicate] lastObject];
        [(NSMutableArray *)__installedApplets addObject:applet];
        [(NSMutableArray *)__availableApplets removeObject:applet];
    }];
    
    // sort system applets
    [(NSMutableArray *)__availableApplets sortUsingComparator:^NSComparisonResult(NSDictionary *one, NSDictionary *two) {
        return [[one objectForKey:@"display_name"] caseInsensitiveCompare:[two objectForKey:@"display_name"]];
    }];
    
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) { return [__installedApplets count]; }
    else { return [__availableApplets count]; }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell"];
    if (indexPath.section == 0) {
        NSDictionary *applet = [__installedApplets objectAtIndex:indexPath.row];
        cell.textLabel.text = [applet objectForKey:@"display_name"];
    }
    else {
        NSDictionary *applet = [__availableApplets objectAtIndex:indexPath.row];
        cell.textLabel.text = [applet objectForKey:@"display_name"];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"\nInstalled Applets";
    }
    else {
        return @"Available Applets";
    }
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
    NSIndexPath *newIndexPath;
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        applet = [__availableApplets objectAtIndex:indexPath.row];
        [self.patient.applets addObject:[applet objectForKey:@"identifier"]];
    }
    else {
        applet = [__installedApplets objectAtIndex:indexPath.row];
        [self.patient.applets removeObject:[applet objectForKey:@"identifier"]];
    }
    [self reloadApplets];
    
    // update table view
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        newIndexPath = [NSIndexPath indexPathForRow:[__installedApplets indexOfObject:applet] inSection:0];
    }
    else {
        newIndexPath = [NSIndexPath indexPathForRow:[__availableApplets indexOfObject:applet] inSection:1];
    }
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
    
    // post notification
    [[NSNotificationCenter defaultCenter]
     postNotificationName:HRAppletConfigurationDidChangeNotification
     object:self];
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
