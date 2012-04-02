//
//  HRKeyValueTableViewController.m
//  HReader
//
//  Created by Marshall Huss on 4/2/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRKeyValueTableViewController.h"


@implementation HRKeyValueTableViewController {
    NSArray *__dataPoints;
}

- (id)initWithDataPoints:(NSArray *)dataPoints {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        __dataPoints = [dataPoints copy];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.allowsSelection = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [__dataPoints count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *dataPoint = [__dataPoints objectAtIndex:indexPath.row];
    cell.textLabel.text = [dataPoint objectForKey:@"title"];
    cell.detailTextLabel.text = [dataPoint objectForKey:@"detail"];
    cell.detailTextLabel.textColor = [dataPoint objectForKey:@"detail_color"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

@end
