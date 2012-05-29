//
//  HRPeopleSetupViewController.h
//  HReader
//
//  Created by Caleb Davenport on 5/29/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "HRGridTableView.h"

@interface HRPeopleSetupViewController : UIViewController <HRGridTableViewDelegate, HRGridTableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) IBOutlet HRGridTableView *gridView;
@property (nonatomic, strong) IBOutlet UIView *emptyCellView;

@property (nonatomic, weak) IBOutlet UIButton *spouseButton;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *emptyCellButtons;

- (IBAction)spouseButtonPress:(id)sender;
- (IBAction)childButtonPress:(id)sender;
- (IBAction)familyMemberButtonPress:(id)sender;

@end
