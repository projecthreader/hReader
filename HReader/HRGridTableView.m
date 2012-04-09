//
//  HRGridTableView.m
//  HReader
//
//  Created by Marshall Huss on 4/9/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRGridTableView.h"
#import "HRGridTableViewCell.h"

@interface HRGridTableView () {
@private
    NSInteger __numberOfViews;
}

@end

@implementation HRGridTableView

@synthesize gridViewDelegate    = __gridViewDelegate;
@synthesize numberOfColumns     = __numberOfColumns;
@synthesize horizontalPadding   = __horizontalPadding;
@synthesize verticalPadding     = __verticalPadding;

#pragma mark - object methods

- (void)commonInit {
    __numberOfColumns = 3;
    UIGestureRecognizer *tapGesture = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(didReceiveTap:)];
    [self addGestureRecognizer:tapGesture];
    self.delegate = self;
    self.dataSource = self;
    self.horizontalPadding = 30.0;
    self.allowsSelection = NO;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)setVerticalPadding:(CGFloat)verticalPadding {
    self.contentInset = UIEdgeInsetsMake(verticalPadding, 0.0, 0.0, 0.0);
    __verticalPadding = verticalPadding;
}

#pragma mark - table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    __numberOfViews = [self.gridViewDelegate numberOfViewsInGridView:self];
    return (NSInteger)ceilf((float)__numberOfViews / (float)self.numberOfColumns);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HRGridTableViewCell *cell = [HRGridTableViewCell cellForTableView:tableView];
    cell.numberOfColumns = self.numberOfColumns;
    cell.horizontalPadding = self.horizontalPadding;
    NSUInteger start = indexPath.row * self.numberOfColumns;
    NSUInteger length = MIN(__numberOfViews - start, self.numberOfColumns);
    NSRange range = NSMakeRange(start, length);
    [cell setViews:[self.gridViewDelegate gridView:self viewsInRange:range]];
    return cell;
}


#pragma mark - gestures

- (void)didReceiveTap:(UIGestureRecognizer *)tapGesture {
    if (tapGesture.state == UIGestureRecognizerStateRecognized) {
        
        // get table view values
        CGPoint tableViewPoint = [tapGesture locationInView:tapGesture.view];
        NSIndexPath *indexPath = [self indexPathForRowAtPoint:tableViewPoint];
        
        // get column values
        NSInteger __block column = -1;
        UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
        CGPoint cellPoint = [cell convertPoint:tableViewPoint fromView:self];
        [cell.contentView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger index, BOOL *stop) {
            if (CGRectContainsPoint(view.frame, cellPoint)) {
                column = index;
                *stop = YES;
            }
        }];
        if (column > -1) {
            NSInteger index = indexPath.row * self.numberOfColumns + column;
            [self.gridViewDelegate gridView:self didSelectViewAtIndex:index];
        }
        
    }
}

@end
