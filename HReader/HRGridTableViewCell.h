//
//  HRGridTableViewCell.h
//  HReader
//
//  Created by Marshall Huss on 4/9/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRGridTableViewCell : UITableViewCell

@property (nonatomic, assign) NSUInteger numberOfColums;
@property (nonatomic, assign) CGFloat paddingSize;

- (void)setViews:(NSArray *)views;

@end
