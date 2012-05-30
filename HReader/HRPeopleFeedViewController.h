//
//  HRPeopleFeedViewController.h
//  HReader
//
//  Created by Caleb Davenport on 5/30/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^HRPeopleFeedViewControllerDidFinishBlock) (NSString *identifier);

@interface HRPeopleFeedViewController : UITableViewController

@property (nonatomic, copy) HRPeopleFeedViewControllerDidFinishBlock didFinishBlock;

- (id)initWithHost:(NSString *)host;

@end
