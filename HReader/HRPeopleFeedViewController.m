//
//  HRPeopleFeedViewController.m
//  HReader
//
//  Created by Caleb Davenport on 5/30/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRPeopleFeedViewController.h"
#import "HRAPIClient_private.h"

#import "NSArray+Collect.h"

@interface HRPeopleFeedViewController (){
@private
    NSString *_host;
    NSArray *_patients;
    UILabel *_statusLabel;
    NSDateFormatter *_dateFormatter;
}

- (void)refresh;
- (void)refresh:(BOOL)ignoreCache;

@end

@implementation HRPeopleFeedViewController

@synthesize didFinishBlock = _didFinishBlock;

- (id)initWithHost:(NSString *)host {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _host = [host copy];
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 500.0);
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // toolbar
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 40.0)];
    _statusLabel.text = @"Loading…";
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.opaque = YES;
    _statusLabel.textColor = [UIColor whiteColor];
    _statusLabel.textAlignment = UITextAlignmentCenter;
    _statusLabel.font = [UIFont boldSystemFontOfSize:14.0];
    _statusLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    _statusLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 34.0;
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)],
                         flexible,
                         [[UIBarButtonItem alloc] initWithCustomView:_statusLabel],
                         flexible,
                         fixed,
                         nil];
    
    // first load
    [self refresh:NO];
    
}

- (void)refresh {
    [self refresh:YES];
}

- (void)refresh:(BOOL)ignoreCache {
    HRAPIClient *client = [HRAPIClient clientWithHost:_host];
    _statusLabel.text = @"Loading…";
    [client patientFeed:^(NSArray *patients) {
        if (patients) {
            NSString *message = [NSString stringWithFormat:
                                 @"Updated: %@",
                                 [_dateFormatter stringFromDate:client->_patientFeedLastFetchDate]];
            _statusLabel.text = message;
        }
        else {
            _statusLabel.text = @"Error";
            NSString *message = [NSString stringWithFormat:
                                 @"An error occurred while fetching the patient list from %@",
                                 _host];
            [[[UIAlertView alloc]
              initWithTitle:@"Error"
              message:message
              delegate:nil
              cancelButtonTitle:@"OK"
              otherButtonTitles:nil]
             show];
        }
        _patients = [patients sortedArrayUsingKey:@"name" ascending:YES];
        [self.tableView reloadData];
    } ignoreCache:ignoreCache];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_patients count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [[_patients objectAtIndex:indexPath.row] objectForKey:@"name"];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HRPeopleFeedViewControllerDidFinishBlock block = self.didFinishBlock;
    if (block) { block([[_patients objectAtIndex:indexPath.row] objectForKey:@"id"]); }
}

@end
