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
#import "HRAppDelegate.h"


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
        //received "save button" click
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
    self.editing = flag;
    
    if (flag == YES){
        // Change views to edit mode.
        //TODO: LMD add cursor?
        
        [self setEditStyleForTextView:self.quantityTextView];
        [self setEditStyleForTextView:self.doseTextView];
        [self setEditStyleForTextView:self.directionsTextView];
        [self setEditStyleForTextView:self.prescriberTextView];
        [self setEditStyleForTextView:self.commentsTextView];
    }
    else {
        
        //save data
        [self.medication setComments:self.commentsTextView.text];
        NSArray *keys = [NSArray arrayWithObjects:@"quantity", @"dose", @"directions", @"prescriber", nil];
        NSArray *objects = [NSArray arrayWithObjects:
                            self.quantityTextView.text,
                            self.doseTextView.text,
                            self.directionsTextView.text,
                            self.prescriberTextView.text,
                            nil];
        [self.medication setPatientComments:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
        
        NSManagedObjectContext *context = [self.medication managedObjectContext];//[HRAppDelegate managedObjectContext];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        
        //change views to noneditable
        [self finishEditForTextView:self.quantityTextView];
        [self finishEditForTextView:self.doseTextView];
        [self finishEditForTextView:self.directionsTextView];
        [self finishEditForTextView:self.prescriberTextView];
        [self finishEditForTextView:self.commentsTextView];
//        self.commentsTextView.layer.borderColor = [[UIColor whiteColor] CGColor];
//        [self.commentsTextView setEditable:NO];
    }
}

- (void) setEditStyleForTextView:(UITextView *)textView{
    textView.layer.borderWidth = 1.0f;
    textView.layer.borderColor = [[UIColor grayColor] CGColor];
    [textView setEditable:YES];
}

- (void) finishEditForTextView:(UITextView *)textView{
    textView.layer.borderColor = [[UIColor whiteColor] CGColor];
    [textView setEditable:NO];
}

@end
