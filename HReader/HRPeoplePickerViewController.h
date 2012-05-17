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
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;

/*
 
 Get the selected patient from the people picker. This object will be pulled
 from the main application managed object context.
 
 */
- (HRMPatient *)selectedPatient;

/*
 
 Toggle the selected patient to the next one in the people picker list. In the
 event of an overflow, the selection will wrap around to the beginning of the
 list.
 
 */
- (void)selectNextPatient;

/*
 
 Toggle the selected patient to the previous one in the people picker list. In
 the event of an overflow, the selection will wrap around to the end of the
 list.
 
 */
- (void)selectPreviousPatient;

@end
