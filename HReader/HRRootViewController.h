//
//  HRRootViewController.h
//  HReader
//
//  Created by Marshall Huss on 11/30/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRRootViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIBarButtonItem *C32ButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *aboutBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *toolsBarButtonItem;

- (IBAction)toolsButtonPressed:(id)sender;

@end
