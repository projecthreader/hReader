//
//  HRAppletConfigurationViewController.m
//  HReader
//
//  Created by Caleb Davenport on 4/13/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRAppletConfigurationViewController.h"

#import "HRMPatient.h"

@interface HRAppletConfigurationViewController () {
@private
    NSArray * __strong __allApplets;
    NSArray * __strong __patientApplets;
    NSArray * __strong __identifiers;
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
    __allApplets = nil;
    [super viewDidUnload];
}

- (void)setPatient:(HRMPatient *)patient {
    if (!__patient || !patient) {
        __patient = patient;
        __identifiers = [__patient.syntheticInfo objectForKey:@"applets"];
    }
}

- (void)reloadApplets {
    
    // load system applets
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"HReaderApplets" withExtension:@"plist"];
    __allApplets = [[NSArray arrayWithContentsOfURL:URL] mutableCopy];
    
    // load patient applets
    __patientApplets = [NSMutableArray arrayWithCapacity:[__identifiers count]];
    [__identifiers enumerateObjectsUsingBlock:^(NSString *identifier, NSUInteger index, BOOL *stop) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier like %@", identifier];
        NSDictionary *applet = [[__allApplets filteredArrayUsingPredicate:predicate] lastObject];
        [(NSMutableArray *)__patientApplets addObject:applet];
        [(NSMutableArray *)__allApplets removeObject:applet];
    }];
    
    // sort system applets
    [(NSMutableArray *)__allApplets sortUsingComparator:^NSComparisonResult(NSDictionary *one, NSDictionary *two) {
        return [[one objectForKey:@"display_name"] caseInsensitiveCompare:[two objectForKey:@"display_name"]];
    }];
    
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) { return [__patientApplets count]; }
    else { return [__allApplets count]; }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell"];
    if (indexPath.section == 0) {
        NSDictionary *applet = [__patientApplets objectAtIndex:indexPath.row];
        cell.textLabel.text = [applet objectForKey:@"display_name"];
    }
    else {
        NSDictionary *applet = [__allApplets objectAtIndex:indexPath.row];
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
    NSMutableArray *identifiers = [__identifiers mutableCopy];
    NSDictionary *applet;
    NSIndexPath *newIndexPath;
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        applet = [__allApplets objectAtIndex:indexPath.row];
        [identifiers addObject:[applet objectForKey:@"identifier"]];
    }
    else {
        applet = [__patientApplets objectAtIndex:indexPath.row];
        [identifiers removeObject:[applet objectForKey:@"identifier"]];
    }
    __identifiers = identifiers;
    [self reloadApplets];
    
    // update table view
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        newIndexPath = [NSIndexPath indexPathForRow:[__patientApplets indexOfObject:applet] inSection:0];
    }
    else {
        newIndexPath = [NSIndexPath indexPathForRow:[__allApplets indexOfObject:applet] inSection:1];
    }
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
