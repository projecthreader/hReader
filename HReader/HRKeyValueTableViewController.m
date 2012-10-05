//
//  HRKeyValueTableViewController.m
//  HReader
//
//  Created by Marshall Huss on 4/2/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRKeyValueTableViewController.h"

@implementation HRKeyValueTableViewController {
    NSArray *_dataPoints;
}

#pragma mark - object methods

- (id)initWithDataPoints:(NSArray *)dataPoints {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _dataPoints = [dataPoints copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataPoints count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    NSDictionary *point = [_dataPoints objectAtIndex:indexPath.row];
    cell.textLabel.text = [point objectForKey:@"title"];
    cell.detailTextLabel.text = [point objectForKey:@"detail"];
    cell.detailTextLabel.textColor = [point objectForKey:@"detail_color"];
    return cell;
}

@end
