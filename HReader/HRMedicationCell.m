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

- (void)setMedication:(HRMEntry *)medication{
    _medication = medication;
    
    if(medication.userDeleted.boolValue){
        //set all content subviews to hidden
        for(UIView *subView in self.contentView.subviews){
            [subView setHidden:YES];
        }
        
        //show medication name with strike-through
        [self.medicationName setAttributedText:[medication getDescAttributeString]];
        [self.medicationName setHidden:NO];
        
        //show delete button as "restore"
        [self.deleteButton setTitle:@"Restore" forState:UIControlStateNormal];
        [self.deleteButton setHidden:NO];
        
    }else{
        //set textViews from medication fields
        [self.medicationName setAttributedText:[medication getDescAttributeString]];//set medication name
        [self.commentsTextView setText:medication.comments];
        [self.quantityTextView setText:[medication.patientComments objectForKey:QUANTITY_KEY]];
        [self.doseTextView setText:[medication.patientComments objectForKey:DOSE_KEY]];
        [self.directionsTextView setText:[medication.patientComments objectForKey:DIRECTIONS_KEY]];
        [self.prescriberTextView setText:[medication.patientComments objectForKey:PRESCRIBER_KEY]];
        
        //set all content subviews to not hidden
        for(UIView *subView in self.contentView.subviews){
            [subView setHidden:NO];
        }
        
        //hide delete button
        [self.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
        [self.deleteButton setHidden:YES];
    }
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
        NSString *editImageFile = [[NSBundle mainBundle] pathForResource:@"edit" ofType:@"png"];
        UIImage *editImage = [UIImage imageWithContentsOfFile:editImageFile];
        [sender setImage:editImage forState:UIControlStateNormal];
        
        [self setEditing:NO animated:YES];
    } else {
        //received "edit button" click
        [sender setTitle:@"Done" forState:UIControlStateNormal];
        NSString *saveImageFile = [[NSBundle mainBundle] pathForResource:@"save" ofType:@"png"];
        UIImage *saveImage = [UIImage imageWithContentsOfFile:saveImageFile];
        [sender setImage:saveImage forState:UIControlStateNormal];
        
        [self setEditing:YES animated:YES];
    }
        
    
}

- (IBAction)setDeleteMedication:(UIButton *)sender {
        
    if(!self.medication.userDeleted.boolValue){
        //delete button- set deleted
        [self.medication setUserDeleted:[NSNumber numberWithBool:YES]];
        
        //make sure button goes back to edit (in case of restore)
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
        NSString *editImageFile = [[NSBundle mainBundle] pathForResource:@"edit" ofType:@"png"];
        UIImage *editImage = [UIImage imageWithContentsOfFile:editImageFile];
        [self.editButton setImage:editImage forState:UIControlStateNormal];
        
        //end editing and save
        [self setEditing:NO animated:YES];
    }else{
        //restore button- set not deleted
        [self.medication setUserDeleted:[NSNumber numberWithBool:NO]];
        
        //save data
        NSManagedObjectContext *context = [self.medication managedObjectContext];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }else{
            //push medication
            [[self.medication patient] pushCommentsForEntry:self.medication];
        }
    }
}

- (void)setEditing:(BOOL)flag animated:(BOOL)animated
{
    self.editing = flag;
    
    if (flag == YES){
        // Change views to edit mode.
        [self setEditStyleForTextView:self.quantityTextView];
        [self setEditStyleForTextView:self.doseTextView];
        [self setEditStyleForTextView:self.directionsTextView];
        [self setEditStyleForTextView:self.prescriberTextView];
        [self setEditStyleForTextView:self.commentsTextView];
        [self.deleteButton setHidden:NO];
    }
    else {
        //change views to noneditable
        [self finishEditForTextView:self.quantityTextView];
        [self finishEditForTextView:self.doseTextView];
        [self finishEditForTextView:self.directionsTextView];
        [self finishEditForTextView:self.prescriberTextView];
        [self finishEditForTextView:self.commentsTextView];

        //set managed object fields from text fields
        NSLog(@"Saving data...");
        [self.medication setComments:self.commentsTextView.text];
        NSArray *keys = [NSArray arrayWithObjects:QUANTITY_KEY, DOSE_KEY, DIRECTIONS_KEY, PRESCRIBER_KEY, nil];
        NSArray *objects = [NSArray arrayWithObjects:
                            self.quantityTextView.text,
                            self.doseTextView.text,
                            self.directionsTextView.text,
                            self.prescriberTextView.text,
                            nil];
        [self.medication setPatientComments:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
        
        //save data
        NSManagedObjectContext *context = [self.medication managedObjectContext];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }else{
            //push medication
            [[self.medication patient] pushCommentsForEntry:self.medication];
        }
    }
}

- (void) setEditStyleForTextView:(UITextView *)textView{
    textView.layer.borderWidth = 1.0f;
    textView.layer.borderColor = [[UIColor grayColor] CGColor];
    textView.layer.cornerRadius = 5;
    [textView setEditable:YES];
}

- (void) finishEditForTextView:(UITextView *)textView{
    textView.layer.borderColor = [[UIColor whiteColor] CGColor];
    [textView setEditable:NO];
}

@end
