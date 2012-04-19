//
//  HRPeoplePickerViewController.h
//  HReader
//
//  Created by Caleb Davenport on 4/18/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

extern NSString * const HRPatientDidChangeNotification;

@class HRMPatient;

@interface HRPeoplePickerViewController : UIViewController

<UITableViewDelegate, UITableViewDataSource,
NSFetchedResultsControllerDelegate,
UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

/*
 
 
 
 */
- (HRMPatient *)selectedPatient;

/*
 
 
 
 */
- (void)selectNextPatient;

/*
 
 
 
 */
- (void)selectPreviousPatient;

@end
