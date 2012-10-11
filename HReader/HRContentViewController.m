//
//  HRContentViewController.m
//  HReader
//
//  Created by Caleb Davenport on 10/11/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRContentViewController.h"
#import "HRPanelViewController.h"
#import "HRPeoplePickerViewController_private.h"
#import "HRAppDelegate.h"
#import "HRMPatient.h"

@implementation HRContentViewController {
    HRMPatient *_patient;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center
         addObserver:self
         selector:@selector(reloadDataWithNotification:)
         name:NSManagedObjectContextDidSaveNotification
         object:nil];
        [center
         addObserver:self
         selector:@selector(reloadDataWithNotification:)
         name:HRSelectedPatientDidChangeNotification
         object:nil];
    }
    return self;
}

- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle {
    self = [super initWithNibName:name bundle:bundle];
    if (self) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center
         addObserver:self
         selector:@selector(reloadDataWithNotification:)
         name:NSManagedObjectContextDidSaveNotification
         object:nil];
        [center
         addObserver:self
         selector:@selector(reloadDataWithNotification:)
         name:HRSelectedPatientDidChangeNotification
         object:nil];
    }
    return self;
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center
     removeObserver:self
     name:NSManagedObjectContextDidSaveNotification
     object:nil];
    [center
     removeObserver:self
     name:HRSelectedPatientDidChangeNotification
     object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // header view shadow
    CALayer *layer = self.headerView.layer;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOpacity = 0.35;
    layer.shadowOffset = CGSizeMake(0.0, 0.0);
    layer.shadowRadius = 5.0;
    layer.shouldRasterize = YES;
    layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [self.view bringSubviewToFront:self.headerView];
    
    // patient image shadow
    layer = self.patientImageView.superview.layer;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOpacity = 0.35;
    layer.shadowOffset = CGSizeMake(0.0, 1.0);
    layer.shadowRadius = 5.0;
    layer.shouldRasterize = YES;
    layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    // gestures
    {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(patientImageViewDidReceiveTap:)];
        gesture.numberOfTapsRequired = 1;
        gesture.numberOfTouchesRequired = 1;
        [self.patientImageView.superview addGestureRecognizer:gesture];
    }
    
    // reload
    [self reloadData];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)reloadData {
    [self reloadDataWithNotification:nil];
}

- (void)reloadDataWithNotification:(NSNotification *)notification {
    
    // get patient
    if (notification) {
        HRMPatient *patient = [[notification userInfo] objectForKey:HRSelectedPatientKey];
        if (patient) { _patient = patient; }
    }
    else if (_patient == nil) {
        NSManagedObjectContext *context = [HRAppDelegate managedObjectContext];
        _patient = [HRPeoplePickerViewController selectedPatientInContext:context];
    }
    
    // configure views
    self.patientImageView.image = [_patient patientImage];
    self.patientNameLabel.text = [[_patient compositeName] uppercaseString];
    
    // reload
    if ([self isViewLoaded]) {
        [self reloadWithPatient:_patient];
    }
    
}

- (void)reloadWithPatient:(HRMPatient *)patient {
    
}

- (void)patientImageViewDidReceiveTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        [(id)self.panelViewController.leftAccessoryViewController selectNextPatient];
    }
}

@end
