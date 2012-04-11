//
//  HRMedicationsAppletTile.h
//  HReader
//
//  Created by Marshall Huss on 4/11/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRAppletTile.h"

@interface HRMedicationsAppletTile : HRAppletTile

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *medicationLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *dosageLabels;

@end
