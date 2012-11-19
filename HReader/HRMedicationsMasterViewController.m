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
    //NSArray *_gridViews;
}

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.title = @"Summary";
    }
    return self;
}

- (void)reloadWithPatient:(HRMPatient *)patient {
    
    // synthetic info
    NSDictionary *syntheticInfo = patient.syntheticInfo;
    
    // date of birth
    if ([self.dateOfBirthTitleLabel.text isEqualToString:@"DOB:"]) {
        self.dateOfBirthLabel.text = [patient.dateOfBirth hr_mediumStyleDate];
    }
    else {
        self.dateOfBirthLabel.text = [patient.dateOfBirth hr_ageString];
    }
    
    // allergies
    {
        NSArray *allergies = [patient.syntheticInfo objectForKey:@"allergies"];
        NSUInteger count = [allergies count];
        self.allergiesLabel.textColor = [UIColor blackColor];
        if (count) {
            NSMutableString *string = [[allergies objectAtIndex:0] mutableCopy];
            if (count > 1) {
                self.allergiesLabel.textColor = [UIColor hr_redColor];
                [string appendFormat:@", %lu more", (unsigned long)(count - 1)];
            }
            if ([string length] > 0) {
                self.allergiesLabel.textColor = [UIColor hr_redColor];
                self.allergiesLabel.text = string;
            }
            else {
                self.allergiesLabel.text = @"None";
            }
        }
        else { self.allergiesLabel.text = @"None"; }
    }
    
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
//    {
//        NSMutableArray *views = [NSMutableArray array];
//        NSArray *identifiers = patient.applets;
//        NSString *token = patient.identityToken;
//        [identifiers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            NSMutableDictionary *applet = [[HRAppletConfigurationViewController appletWithIdentifier:obj] mutableCopy];
//            [applet setObject:token forKey:HRAppletTilePatientIdentityTokenKey];
//            if ([obj rangeOfString:@"org.mitre.hreader"].location == 0) {
//                [applet setObject:patient forKey:@"__private_patient__"];
//            }
//            if (applet) {
//                Class c = NSClassFromString([applet objectForKey:@"class_name"]);
//                [views addObject:[c tileWithUserInfo:applet]];
//            }
//            else { NSLog(@"Unable to load applet with identifier %@", obj); }
//        }];
//        _gridViews = views;
//        [self.gridView reloadData];
//        
//    }

    
}

- (void)appletConfigurationDidChange {
    [self reloadData];
}

#pragma mark - view methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // date of birth tap
    NSArray *array = [NSArray arrayWithObjects:self.dateOfBirthLabel, self.dateOfBirthTitleLabel, nil];
    [array enumerateObjectsUsingBlock:^(UIView *view, NSUInteger index, BOOL *stop) {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(toggleDateOfBirth:)];
        [view addGestureRecognizer:gesture];
    }];
    
    
    // gestures
//    {
//        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
//                                           initWithTarget:self
//                                           action:@selector(conditionsContainerViewTap:)];
//        gesture.numberOfTapsRequired = 1;
//        gesture.numberOfTouchesRequired = 1;
//        [self.currentMedicationsView addGestureRecognizer:gesture];
//    }
//    {
//        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
//                                           initWithTarget:self
//                                           action:@selector(eventsContainerViewTap:)];
//        gesture.numberOfTapsRequired = 1;
//        gesture.numberOfTouchesRequired = 1;
//        [self.upcomingRefillsView addGestureRecognizer:gesture];
//    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - collection view

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HRMedicationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MedicationCellReuseID" forIndexPath:indexPath];
    
    HRMPatient *currentPatient = [HRPeoplePickerViewController selectedPatient];
    
    HRMEntry *medication = [currentPatient.medications objectAtIndex:indexPath.item];
    
    [cell.medicationName setText:medication.desc];//set medication name
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    HRMPatient *currentPatient = [HRPeoplePickerViewController selectedPatient];
    return [currentPatient.medications count];
}

#pragma mark - gestures

- (void)toggleDateOfBirth:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if ([self.dateOfBirthTitleLabel.text isEqualToString:@"DOB:"]) {
            self.dateOfBirthTitleLabel.text = @"AGE:";
        }
        else {
            self.dateOfBirthTitleLabel.text = @"DOB:";
        }
        [self reloadData];
    }
}

//- (void)conditionsContainerViewTap:(UITapGestureRecognizer *)gesture {
//    if (gesture.state == UIGestureRecognizerStateRecognized) {
//        HRMPatient *patient = [(id)self.panelViewController.leftAccessoryViewController selectedPatient];
//        NSString *imageName = [NSString stringWithFormat:@"%@-condition-full", [patient initials]];
//        UIImage *image = [UIImage imageNamed:imageName];
//        if (image) {
//            UIViewController *controller = [[UIViewController alloc] init];
//            controller.title = @"Conditions";
//            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//            imageView.frame = controller.view.bounds;
//            imageView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
//            [controller.view addSubview:imageView];
//            [self.navigationController pushViewController:controller animated:YES];   
//        }
//    }
//}
//
//- (void)eventsContainerViewTap:(UITapGestureRecognizer *)gesture {
//    if (gesture.state == UIGestureRecognizerStateRecognized) {
//        HRMPatient *patient = [(id)self.panelViewController.leftAccessoryViewController selectedPatient];
//        NSString *imageName = [NSString stringWithFormat:@"%@-events-full", [patient initials]];
//        UIImage *image = [UIImage imageNamed:imageName];
//        if (image) {
//            UIViewController *controller = [[UIViewController alloc] init];
//            controller.title = @"Recent Events";
//            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//            imageView.frame = controller.view.bounds;
//            imageView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
//            [controller.view addSubview:imageView];
//            [self.navigationController pushViewController:controller animated:YES];   
//        }
//    }
//}

- (void)viewDidUnload {
    [self setCollectionView:nil];
    [self setMedicationRefillLabels:nil];
    [self setMedicationRefillLabels:nil];
    [self setRefillLocationLabels:nil];
    [self setMedicationRefillLabels:nil];
    [self setMedicationRefillLabels:nil];
    [super viewDidUnload];
}
@end
