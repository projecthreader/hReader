//
//  HRMedicationsMasterViewController.m
//  HReader
//
//  Created by DiCristofaro, Lauren M on 11/13/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRMedicationsMasterViewController.h"
#import "HRAppletConfigurationViewController.h"
#import "HRPeoplePickerViewController.h"
#import "HRAppletTile.h"
#import "HRAppDelegate.h"
#import "HRMPatient.h"
#import "HRMEntry.h"
#import "HRPanelViewController.h"
#import "HRMedicationCell.h"
#import "HRPeoplePickerViewController_private.h"

#import "NSString+SentenceCapitalization.h"

@implementation HRMedicationsMasterViewController {
    id _keyboardWillShowObserver;
    id _keyboardWillHideObserver;
}

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.title = @"Medications";
        
        //add keyboard show observer
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        __weak HRMedicationsMasterViewController *weakSelf = self;
        [center
         addObserverForName:UIKeyboardWillShowNotification
         object:nil
         queue:[NSOperationQueue mainQueue]
         usingBlock:^(NSNotification *notification) {
             HRMedicationsMasterViewController *strongSelf = weakSelf;
             if (strongSelf) {
                 [strongSelf keyboardWillShow:notification];
             }
         }];
        
        //add keyboard hide observer
        [center
         addObserverForName:UIKeyboardWillHideNotification
         object:nil
         queue:[NSOperationQueue mainQueue]
         usingBlock:^(NSNotification *notification) {
             HRMedicationsMasterViewController *strongSelf = weakSelf;
             if (strongSelf) {
                 [strongSelf keyboardWillHide:notification];
             }
         }];
        
        //add data
        [self initializeData];
    }
    return self;
}


- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center
     removeObserver:_keyboardWillHideObserver
     name:UIKeyboardWillHideNotification
     object:nil];
    [center
     removeObserver:_keyboardWillShowObserver
     name:UIKeyboardWillShowNotification
     object:nil];
}


- (void)reloadWithPatient:(HRMPatient *)patient {
    
    // synthetic info
    NSDictionary *syntheticInfo = patient.syntheticInfo;
    
    // medications
    {
        NSArray *medications = [patient medications];
        NSArray *nameLabels = [self.medicationNameLabels hr_sortedArrayUsingKey:@"tag" ascending:YES];
        NSArray *dosageLabels = [self.medicationDosageLabels hr_sortedArrayUsingKey:@"tag" ascending:YES];
        NSUInteger medicationsCount = [medications count];
        NSUInteger labelCount = [nameLabels count];
        BOOL showCountLabel = (medicationsCount > labelCount);
        NSAssert(labelCount == [dosageLabels count], @"There must be an equal number of name and dosage labels");
        [nameLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
            
            // this is the last label and we should show count
            if (index == labelCount - 1 && showCountLabel) {
                label.text = [NSString stringWithFormat:@"%lu more…", (unsigned long)(medicationsCount - labelCount + 1)];
            }
            
            // normal medication label
            else if (index < medicationsCount) {
                HRMEntry *medication = [medications objectAtIndex:index];
                label.text = [medication.desc sentenceCapitalizedString];
            }
            
            // no medications
            else if (index == 0) { label.text = @"None"; }
            
            // clear the label
            else { label.text = nil; }
            
        }];
        [dosageLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
            if (index == labelCount - 1 && showCountLabel) {
                label.text = nil;
            }
            else if (index < medicationsCount) {
                HRMEntry *medication = [medications objectAtIndex:index];
                //TODO: LMD- currently dosage is just empty string
                //figure out how dose dictionary works (find key)
                //label.text = [medication.dose objectForKey:@""];
                label.text = nil;
            }
            else { label.text = nil; }
        }];
    }
    
    //refills
    {
        NSArray *medications = [patient medications];
        NSArray *nameLabels = [self.medicationRefillLabels hr_sortedArrayUsingKey:@"tag" ascending:YES];
        NSArray *locationLabels = [self.refillLocationLabels hr_sortedArrayUsingKey:@"tag" ascending:YES];
        NSUInteger medicationsCount = [medications count];
        NSUInteger labelCount = [nameLabels count];
        BOOL showCountLabel = (medicationsCount > labelCount);
        NSAssert(labelCount == [locationLabels count], @"There must be an equal number of name and location labels");
        [nameLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
            
            // this is the last label and we should show count
            if (index == labelCount - 1 && showCountLabel) {
                label.text = [NSString stringWithFormat:@"%lu more…", (unsigned long)(medicationsCount - labelCount + 1)];
            }
            
            // normal medication label
            else if (index < medicationsCount) {
                HRMEntry *medication = [medications objectAtIndex:index];
                label.text = [medication.desc sentenceCapitalizedString];
            }
            
            // no medications
            else if (index == 0) { label.text = @"None"; }
            
            // clear the label
            else { label.text = nil; }
            
        }];
        [locationLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
            if (index == labelCount - 1 && showCountLabel) {
                label.text = nil;
            }
            else if (index < medicationsCount) {
                HRMEntry *medication = [medications objectAtIndex:index];
                //TODO: LMD- currently location is just empty string
                //figure out how refill information works
                //label.text = [medication.? objectForKey:@""];
                label.text = nil;
            }
            else { label.text = nil; }
        }];
    }
    
        
    // Medication details
    {
        [self.collectionView reloadData];
    }
    
    // applets

}

- (void)appletConfigurationDidChange {
    [self reloadData];
}

#pragma mark - view methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - collection view

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    HRMedicationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MedicationCellReuseID" forIndexPath:indexPath];
    
    [cell setMedication:[self.medicationList objectAtIndex:indexPath.item]];

    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
//    HRMPatient *currentPatient = [HRPeoplePickerViewController selectedPatient];
//    NSUInteger cnt = [currentPatient.medications count];
//    NSLog(@"Number of items in section: %d", [self.medicationList count]);
//    return [currentPatient.medications count];
    return [self.medicationList count];
}

#pragma mark - gestures



- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    double duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSUInteger options = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] doubleValue];
    [UIView
     animateWithDuration:duration
     delay:0.0
     options:options
     animations:^{
//         CGRect keyboardEndFrame;
//         [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
//         
//         NSLog(@"keyboard frame end values: %f, %f", keyboardEndFrame.size.height, keyboardEndFrame.size.width);
         
         //to move header view up by the headerView's height
         CGFloat newHeaderOriginY = self.headerView.frame.origin.y -
                                               self.headerView.frame.size.height;
         //to move collection view up by the headerView's height
         CGFloat newCollectionOriginY = self.collectionView.frame.origin.y -
                                                   self.headerView.frame.size.height;
         self.headerView.frame = CGRectMake(self.headerView.frame.origin.x,
                                            newHeaderOriginY,
                                            self.headerView.frame.size.width,
                                            self.headerView.frame.size.height);
         self.collectionView.frame = CGRectMake(self.collectionView.frame.origin.x,
                                            newCollectionOriginY,
                                            self.collectionView.frame.size.width,
                                            self.collectionView.frame.size.height);
         
     }
     completion:^(BOOL finished) {
         
     }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    double duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSUInteger options = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] doubleValue];
    [UIView
     animateWithDuration:duration
     delay:0.0
     options:options
     animations:^{
//         CGRect keyboardEndFrame;
//         [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
         
         //to move header view down by the headerView's height
         CGFloat newHeaderOriginY = self.headerView.frame.origin.y +
         self.headerView.frame.size.height;
         //to move collection view down by the headerView's height
         CGFloat newCollectionOriginY = self.collectionView.frame.origin.y +
         self.headerView.frame.size.height;
         self.headerView.frame = CGRectMake(self.headerView.frame.origin.x,
                                            newHeaderOriginY,
                                            self.headerView.frame.size.width,
                                            self.headerView.frame.size.height);
         self.collectionView.frame = CGRectMake(self.collectionView.frame.origin.x,
                                                newCollectionOriginY,
                                                self.collectionView.frame.size.width,
                                                self.collectionView.frame.size.height);
         //[self reloadInputViews];
         
     }
     completion:^(BOOL finished) {
         
     }];
}

- (void)viewDidUnload {
    [self setCollectionView:nil];
    [self setMedicationRefillLabels:nil];
    [self setMedicationRefillLabels:nil];
    [self setRefillLocationLabels:nil];
    [self setMedicationRefillLabels:nil];
    [self setMedicationRefillLabels:nil];
    [super viewDidUnload];
}

- (void)initializeData{
    NSLog(@"Initializing data");
    HRMPatient *currentPatient = [HRPeoplePickerViewController selectedPatient];
    self.medicationList = [currentPatient medications];
    
    for(NSUInteger i=0;i<self.medicationList.count;i++){
        HRMEntry *med = [self.medicationList objectAtIndex:i];
        if(med.comments == nil){
            med.comments = @"-";
        }
        
        if(med.patientComments == nil){
            NSLog(@"patient comments for entry %d are nil, setting to dashes", i);
            //codes,dose,date,desc,endDate,startDate,status,value,type,patient,reaction,severity
            NSArray *keys = [NSArray arrayWithObjects:@"quantity", @"dose", @"directions", @"prescriber", nil];
            NSArray *objects = [NSArray arrayWithObjects:@"-", @"-", @"-", @"-", nil];
            [med setPatientComments:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
        }
        
        NSManagedObjectContext *context = [med managedObjectContext];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    
    
}
@end
