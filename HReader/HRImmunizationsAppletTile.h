//
//  HRImmunizationsAppletTile.h
//  HReader
//
//  Created by Marshall Huss on 4/11/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRAppletTile.h"

@interface HRImmunizationsAppletTile : HRAppletTile

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *immunizationLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *dateLabels;

@end
