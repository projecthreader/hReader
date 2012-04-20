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
#import "HRImageAppletTile.h"

#import "NSArray+Collect.h"

@interface HRDoctorsViewController ()
- (void)reloadData;
- (void)reloadDataAnimated;
@end

@implementation HRDoctorsViewController {
    NSArray * __strong __providerViews;
}

@synthesize nameLabel       = __nameLabel;
@synthesize gridTableView   = __gridTableView;

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.title = @"Providers";
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    HRAppletTile *tile = [__providerViews objectAtIndex:index];
    CGRect rect = [self.view convertRect:tile.bounds fromView:tile];
    [tile didReceiveTap:self inRect:rect];
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
//    NSArray *providers = [[HRMPatient selectedPatient] valueForKeyPath:@"syntheticInfo.providers"];
//    NSMutableArray *views = [[NSMutableArray alloc] initWithCapacity:[providers count]];
//    UINib *nib = [UINib nibWithNibName:@"HRProviderView" bundle:nil];
    self.nameLabel.text = [[patient compositeName] uppercaseString];
    
    // configure views
    
    // health gateway
    // Loading mockups by file name convention
    NSMutableArray *views = [[NSMutableArray alloc] init];
    for (int i = 0; i < 6; i++) {
        NSString *imagePrefix = [NSString stringWithFormat:@"%@-%d", [patient initials], i];
        NSDictionary *userInfo = 
        [NSDictionary dictionaryWithObjectsAndKeys:
         [NSString stringWithFormat:@"%@-tile", imagePrefix], @"tile_image", 
         [NSString stringWithFormat:@"%@-overview", imagePrefix], @"fullscreen_image",
         nil];
        HRImageAppletTile *tile = [HRImageAppletTile tileWithPatient:patient userInfo:userInfo];
        [views addObject:tile];
    }

    /*
    NSArray *imagePrefixes = [NSArray arrayWithObjects:@"dentist", @"insurance", @"pharmacy", nil];
    NSMutableArray *imageApplets = [[NSMutableArray alloc] initWithCapacity:[imagePrefixes count]];
    [imagePrefixes enumerateObjectsUsingBlock:^(NSString *imagePrefix, NSUInteger idx, BOOL *stop) {
        NSDictionary *userInfo = 
        [NSDictionary dictionaryWithObjectsAndKeys:
         [NSString stringWithFormat:@"%@-summary", imagePrefix], @"tile_image", 
         [NSString stringWithFormat:@"%@-overview", imagePrefix], @"fullscreen_image",
         nil];
        HRImageAppletTile *tile = [HRImageAppletTile tileWithPatient:patient userInfo:userInfo];
        [imageApplets addObject:tile];
    }];
     */

    
    // providers
    /*
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
        [views addObject:view];
    }];
     */
    
    // save and reload
    __providerViews = views;
    [self.gridTableView reloadData];
    
}

@end
