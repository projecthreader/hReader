//
//  HRGridTableViewCell.m
//  HReader
//
//  Created by Marshall Huss on 4/9/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRGridTableViewCell.h"

@implementation HRGridTableViewCell

@synthesize numberOfColums      = __numberOfColums;
@synthesize paddingSize         = __paddingSize;

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
        __paddingSize = 30;
        __numberOfColums = 3;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat totalColumnWidth = self.contentView.bounds.size.width - ((self.numberOfColums + 1) * self.paddingSize);
    CGFloat columnWidth = totalColumnWidth / self.numberOfColums;
    CGFloat rowHeight = self.contentView.bounds.size.height - self.paddingSize;
    NSLog(@"%@", NSStringFromCGRect(self.contentView.frame));
    [self.contentView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        view.frame = CGRectMake(self.paddingSize + ((self.paddingSize + columnWidth) * idx), 0, columnWidth, rowHeight);
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
