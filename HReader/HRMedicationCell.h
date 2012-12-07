//
//  HRMedicationCell.h
//  HReader
//
//  Created by DiCristofaro, Lauren M on 11/13/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HRMEntry;

@interface HRMedicationCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *medicationName;
@property (weak, nonatomic) IBOutlet UITextView *quantityTextView;
@property (weak, nonatomic) IBOutlet UITextView *doseTextView;
@property (weak, nonatomic) IBOutlet UITextView *directionsTextView;
@property (weak, nonatomic) IBOutlet UITextView *prescriberTextView;
@property (weak, nonatomic) IBOutlet UITextView *commentsTextView;


@property (assign) BOOL editing;
@property (strong, nonatomic) HRMEntry *medication;

- (IBAction)setEditMode:(UIButton *)sender;

@end
