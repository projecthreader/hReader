//
//  HRGridTableView.m
//  HReader
//
//  Created by Marshall Huss on 4/9/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRGridTableView.h"
#import "HRGridTableViewCell.h"

#if !__has_feature(objc_arc)
#error This class requires ARC
#endif

@interface HRGridTableView () {
@private
    NSInteger _numberOfViews;
}

- (void)didReceiveTap:(UITapGestureRecognizer *)gesture;
- (void)commonInit;

@end

@implementation HRGridTableView

@synthesize gridViewDelegate = _gridViewDelegate;
@synthesize gridViewDataSource = _gridViewDataSource;
@synthesize numberOfColumns = _numberOfColumns;
@synthesize horizontalPadding = _horizontalPadding;
@synthesize verticalPadding = _verticalPadding;

#pragma mark - object methods

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) { [self commonInit]; }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) { [self commonInit]; }
    return self;
}

- (void)commonInit {
    _numberOfColumns = 3;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(didReceiveTap:)];
    gesture.numberOfTapsRequired = 1;
    gesture.numberOfTouchesRequired = 1;
    gesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:gesture];
    self.delegate = self;
    self.dataSource = self;
    self.horizontalPadding = 30.0;
    self.allowsSelection = NO;
}

- (void)setVerticalPadding:(CGFloat)verticalPadding {
    self.contentInset = UIEdgeInsetsMake(verticalPadding, 0.0, 0.0, 0.0);
    _verticalPadding = verticalPadding;
}

#pragma mark - table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    _numberOfViews = [self.gridViewDataSource numberOfViewsInGridView:self];
    return (NSInteger)ceilf((float)_numberOfViews / (float)self.numberOfColumns);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HRGridTableViewCell *cell = [HRGridTableViewCell cellForTableView:tableView];
    cell.numberOfColumns = self.numberOfColumns;
    cell.horizontalPadding = self.horizontalPadding;
    cell.verticalPadding = self.verticalPadding;
    NSUInteger start = indexPath.row * self.numberOfColumns;
    NSUInteger length = MIN(_numberOfViews - start, self.numberOfColumns);
    NSMutableArray *views = [NSMutableArray arrayWithCapacity:length];
    for (NSUInteger i = start; i < start + length; i++) {
        [views addObject:[self.gridViewDataSource gridView:self viewAtIndex:i]];
    }
    [cell setViews:views];
    return cell;
}


#pragma mark - gestures

- (void)didReceiveTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        
        // get table view values
        CGPoint tableViewPoint = [gesture locationInView:gesture.view];
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
            if ([self.gridViewDelegate respondsToSelector:@selector(gridView:didSelectViewAtIndex:)]) {
                [self.gridViewDelegate gridView:self didSelectViewAtIndex:index];
            }
        }
        
    }
}

@end
