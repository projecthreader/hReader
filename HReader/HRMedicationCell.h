//
//  HRMedicationCell.h
//  HReader
//
//  Created by DiCristofaro, Lauren M on 11/13/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRMedicationCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *medicationName;
@property (assign) BOOL editing;
@property (weak, nonatomic) IBOutlet UITextView *commentsTextView;

- (IBAction)setEditMode:(UIButton *)sender;

@end
