//
//  HRVitalView.h
//  HReader
//
//  Created by Marshall Huss on 2/8/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HRVital;

@interface HRVitalView : UIView

@property (retain, nonatomic) HRVital *vital;

@property (retain, nonatomic) IBOutlet UILabel *leftLabel;
@property (retain, nonatomic) IBOutlet UILabel *rightLabel;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *resultLabel;
@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UILabel *normalLabel;
@property (retain, nonatomic) IBOutlet UIImageView *graphImageView;
@property (retain, nonatomic) IBOutlet UILabel *unitsLabel;

@end
