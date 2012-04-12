//
//  HRDoctorsViewController.m
//  HReader
//
//  Created by Marshall Huss on 12/2/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRDoctorsViewController.h"
#import "HRPatientSwipeControl.h"
#import "HRMPatient.h"
#import "HRProviderView.h"
#import "NSArray+Collect.h"

@interface HRDoctorsViewController ()
- (void)reloadData;
- (void)reloadDataAnimated;
@end

@implementation HRDoctorsViewController {
    NSArray * __strong __providerViews;
}

@synthesize nameLabel = __nameLabel;
@synthesize gridTableView = __gridTableView;

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.title = @"Doctors";
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // grid view
    self.gridTableView.horizontalPadding = 34.0;
    self.gridTableView.verticalPadding = 42.0;
    self.gridTableView.rowHeight = 150.0 + 42.0;
    
    // load patient swipe
    HRPatientSwipeControl *swipe = [HRPatientSwipeControl
                                    controlWithOwner:self
                                    options:nil 
                                    target:self
                                    action:@selector(patientChanged:)];
    [self.view addSubview:swipe];
    
    // reload
    [self reloadData];
    
}

- (void)viewDidUnload {
    self.nameLabel = nil;
    self.gridTableView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - NSNotificationCenter

- (void)patientChanged:(HRPatientSwipeControl *)sender {
    [self reloadDataAnimated];
}

#pragma mark - grid table view delegate

- (NSInteger)numberOfViewsInGridView:(HRGridTableView *)gridView {
    return [__providerViews count];
}

- (NSArray *)gridView:(HRGridTableView *)gridView viewsInRange:(NSRange)range {
    return [__providerViews subarrayWithRange:range];
}

- (void)gridView:(HRGridTableView *)gridView didSelectViewAtIndex:(NSInteger)index {
    // selected doctor
}

#pragma mark - private methods

- (void)reloadDataAnimated {
    [UIView animateWithDuration:0.4 animations:^{
        self.nameLabel.alpha = 0.0;
        self.gridTableView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self reloadData];
        [UIView animateWithDuration:0.4 animations:^{
            self.nameLabel.alpha = 1.0;
            self.gridTableView.alpha = 1.0;
        }];
    }];       
}

- (void)reloadData {
    
    // initial setup
    HRMPatient *patient = [HRMPatient selectedPatient];
    NSArray *providers = [[HRMPatient selectedPatient] valueForKeyPath:@"syntheticInfo.providers"];
    NSLog(@"%@", patient.syntheticInfo);
    NSMutableArray *views = [[NSMutableArray alloc] initWithCapacity:[providers count]];
    UINib *nib = [UINib nibWithNibName:@"HRProviderView" bundle:nil];
    self.nameLabel.text = [[patient compositeName] uppercaseString];
    
    // configure views
    [providers enumerateObjectsUsingBlock:^(NSDictionary *provider, NSUInteger idx, BOOL *stop) {
        HRProviderView *view = [[nib instantiateWithOwner:self options:nil] lastObject];
        view.specialityLabel.text = [provider objectForKey:@"speciality"];
        view.nameLabel.text = [NSString stringWithFormat:@"%@ %@ %@",
                               [provider objectForKey:@"title"],
                               [provider objectForKey:@"first_name"],
                               [provider objectForKey:@"last_name"]];
        view.organizationLabel.text = [provider objectForKey:@"organization"];
        view.phoneNumberLabel.text = [provider objectForKey:@"phone_number"];
        view.addressLabel.text = [NSString stringWithFormat:@"%@\n%@ %@",
                                  [provider objectForKey:@"street"],
                                  [provider objectForKey:@"city"],
//                                  [provider objectForKey:@"state"],
                                  [provider objectForKey:@"zip"]];
//                          "speciality": "Endocrinologist",
//                          "title": "Dr.",
//                          "first_name": "Franklin",
//                          "last_name": "Purch",
//                          "organization": "Medical West",
//                          "street": "265 Chestnut Street",
//                          "city": "Dedham",
//                          "zip": "12345",
//                          "phone_number": "(781) 453-3000",
//                          "email": "fpurch@fakeemail.com"
        [views addObject:view];
    }];
    
    // save and reload
    __providerViews = views;
    [self.gridTableView reloadData];
    
}

@end
