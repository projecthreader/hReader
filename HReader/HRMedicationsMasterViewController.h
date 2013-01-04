//
//  HRMedicationsMasterViewController.h
//  HReader
//
//  Created by DiCristofaro, Lauren M on 11/13/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRContentViewController.h"

@interface HRMedicationsMasterViewController : HRContentViewController <UICollectionViewDelegate, UICollectionViewDataSource>

// container views
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

// current medications
@property (nonatomic, weak) IBOutlet UIView *currentMedicationsView;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *medicationNameLabels;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *medicationDosageLabels;

// upcoming refills
@property (nonatomic, weak) IBOutlet UIView *upcomingRefillsView;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *medicationRefillLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *refillLocationLabels;

//data
@property (nonatomic, copy) NSArray *medicationList;

@end
