//
//  HRMedicationCell.m
//  HReader
//
//  Created by DiCristofaro, Lauren M on 11/13/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HRMedicationCell.h"
#import "HRPeoplePickerViewController_private.h"
#import "HRMPatient.h" 
#import "HRMEntry.h"


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
        //TODO: LMD acquire image more gracefully (relative path?)
        NSString *editImageFile = @"/Users/laurend/Dev/hReaderProject/HReader/edit.png";
        UIImage *editImage = [UIImage imageWithContentsOfFile:editImageFile];
        [sender setImage:editImage forState:UIControlStateNormal];
        
        [self setEditing:NO animated:YES];
    } else {
        [sender setTitle:@"Done" forState:UIControlStateNormal];
        NSString *saveImageFile = @"/Users/laurend/Dev/hReaderProject/HReader/save.png";
        UIImage *saveImage = [UIImage imageWithContentsOfFile:saveImageFile];
        [sender setImage:saveImage forState:UIControlStateNormal];
        
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
        //TODO: LMD add cursor?
        self.commentsTextView.layer.borderWidth = 1.0f;
        self.commentsTextView.layer.borderColor = [[UIColor grayColor] CGColor];
        [self.commentsTextView setEditable:YES];
    }
    else {
        // Save the changes if needed and change the views to noneditable.
        NSLog(@"log statement %d", 4);
        
        //save data
//        HRMPatient *currentPatient = [HRPeoplePickerViewController selectedPatient];
//        CMDManagedObject *medication = [currentPatient.medications objectAtIndex:0];
//        [medication setValue:self.commentsTextView.text forKey:@"comments"];
//        
//        NSManagedObjectContext *context = [medication managedObjectContext];
//        
//        NSError *error;
//        if (![context save:&error]) {
//            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//        }
        
        
        //change to noneditable
        self.commentsTextView.layer.borderColor = [[UIColor whiteColor] CGColor];
        [self.commentsTextView setEditable:NO];
    }
}

@end
