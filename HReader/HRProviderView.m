//
//  HRDoctorInfoView.m
//  HReader
//
//  Created by Marshall Huss on 2/27/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRProviderView.h"

@implementation HRProviderView

@synthesize provider                = __provider;

@synthesize specialityLabel         = __specialityLabel;
@synthesize nameLabel               = __nameLabel;
@synthesize organizationLabel       = __organizationLabel;
@synthesize addressLabel            = __addressLabel;
@synthesize phoneNumberLabel        = __phoneNumberLabel;


- (void)dealloc {
    self.provider = nil;
    self.specialityLabel = nil;
    self.nameLabel = nil;
    self.organizationLabel = nil;
    self.addressLabel = nil;
    self.phoneNumberLabel = nil;
    
    [super dealloc];
}

- (void)setProvider:(HRMProvider *)provider {
    [__provider release];
    __provider = [provider retain];
    
//    self.specialityLabel.text = __provider.speciality;
//    self.nameLabel.text = [__provider compositeName];
//    self.organizationLabel.text = __provider.organization;
//    self.addressLabel.text = __provider.address;
//    self.phoneNumberLabel.text = __provider.phoneNumber;
}
    
@end
