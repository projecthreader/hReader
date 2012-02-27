//
//  HRDoctorInfoView.h
//  HReader
//
//  Created by Marshall Huss on 2/27/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HRMProvider;

@interface HRProviderView : UIView

@property (strong, nonatomic) HRMProvider *provider;

@property (strong, nonatomic) IBOutlet UILabel *specialityLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *organizationLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *phoneNumberLabel;

@end
