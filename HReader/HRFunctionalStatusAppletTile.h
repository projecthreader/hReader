//
//  HRFunctionalStatusAppletTile.h
//  HReader
//
//  Created by Marshall Huss on 4/13/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRAppletTile.h"

@interface HRFunctionalStatusAppletTile : HRAppletTile

@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UILabel *problemLabel;
@property (retain, nonatomic) IBOutlet UILabel *typeLabel;
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;

@end
