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

@required
- (NSUInteger)numberOfViewsInGridView:(HRGridTableView *)gridView;
- (NSArray *)gridView:(HRGridTableView *)gridView viewsInRange:(NSRange)range;

@optional
- (void)gridView:(HRGridTableView *)gridView didSelectViewAtIndex:(NSInteger)index;

@end

@interface HRGridTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) IBOutlet id<HRGridTableViewDelegate> gridViewDelegate;
@property (nonatomic, assign) NSUInteger numberOfColumns;
@property (nonatomic, assign) CGFloat horizontalPadding;
@property (nonatomic, assign) CGFloat verticalPadding;

@end
