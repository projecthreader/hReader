//
//  HRMedicationCell.m
//  HReader
//
//  Created by DiCristofaro, Lauren M on 11/13/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRMedicationCell.h"

@implementation HRMedicationCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)setEditMode:(UIButton *)sender {
    
    if (self.editing) {
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
        
        [self setEditing:NO animated:YES];
    } else {
        [sender setTitle:@"Done" forState:UIControlStateNormal];
        
        [self setEditing:YES animated:YES];
    }
        
    
}

- (void)setEditing:(BOOL)flag animated:(BOOL)animated
{
    //TODO: LMD change to text view? how to get rid of keyboard? toggle border? save typed text
    self.editing = flag;
    
    if (flag == YES){
        // Change views to edit mode.
        NSLog(@"log statement %d", 3);
        self.commentsTextField.text = @"Text field Editable";
    }
    else {
        // Save the changes if needed and change the views to noneditable.
        NSLog(@"log statement %d", 4);
        self.commentsTextField.text = @"-";
    }
}

@end
