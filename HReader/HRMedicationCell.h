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
@property (weak, nonatomic) IBOutlet UITextField *commentsTextField;
@property (weak, nonatomic) IBOutlet UILabel *patientCommentsLabel;
@property (assign) BOOL editing;

- (IBAction)setEditMode:(UIButton *)sender;

@end
