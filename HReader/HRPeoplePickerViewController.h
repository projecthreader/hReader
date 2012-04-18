//
//  HRPeoplePickerViewController.h
//  HReader
//
//  Created by Caleb Davenport on 4/18/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface HRPeoplePickerViewController : UIViewController

<UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
