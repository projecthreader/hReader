//
//  HRGridTableView.h
//  HReader
//
//  Created by Marshall Huss on 4/9/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HRGridTableView;

@protocol HRGridTableViewDelegate <NSObject>

@optional
- (void)gridView:(HRGridTableView *)gridView didSelectViewAtIndex:(NSUInteger)index;

@end

@protocol HRGridTableViewDataSource <NSObject>

@required
- (NSUInteger)numberOfViewsInGridView:(HRGridTableView *)gridView;
- (UIView *)gridView:(HRGridTableView *)gridView viewAtIndex:(NSUInteger)index;

@end

@interface HRGridTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet id<HRGridTableViewDelegate> gridViewDelegate;
@property (nonatomic, weak) IBOutlet id<HRGridTableViewDataSource> gridViewDataSource;
@property (nonatomic, assign) NSUInteger numberOfColumns;
@property (nonatomic, assign) CGFloat horizontalPadding;
@property (nonatomic, assign) CGFloat verticalPadding;

@end
