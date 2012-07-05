//
//  HRGridTableViewCell.m
//  HReader
//
//  Created by Marshall Huss on 4/9/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRGridTableViewCell.h"

@implementation HRGridTableViewCell

@synthesize numberOfColumns = _numberOfColumns;
@synthesize horizontalPadding = _horizontalPadding;
@synthesize verticalPadding = _verticalPadding;

#pragma mark - class methods

+ (HRGridTableViewCell *)cellForTableView:(UITableView *)tableView {
    NSString *identifier = NSStringFromClass([self class]);
    HRGridTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[HRGridTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

#pragma object methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _horizontalPadding = 30;
        _verticalPadding = 30;
        _numberOfColumns = 3;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat totalColumnWidth = self.contentView.bounds.size.width - (self.numberOfColumns + 1) * self.horizontalPadding;
    CGFloat columnWidth = totalColumnWidth / self.numberOfColumns;
    CGFloat rowHeight = self.contentView.bounds.size.height - self.verticalPadding;
    [self.contentView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        view.frame = CGRectMake(floor(self.horizontalPadding + ((self.horizontalPadding + columnWidth) * idx)),
                                0.0,
                                floor(columnWidth),
                                floor(rowHeight));
    }];
}

- (void)setViews:(NSArray *)views {
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIView *contentView = self.contentView;
    [views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [contentView addSubview:view];
    }];    
    [self setNeedsLayout];
}

@end
