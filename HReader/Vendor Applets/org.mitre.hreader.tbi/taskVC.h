//
//  taskVC.h
//  HReader
//
//  Created by Saltzman, Shep on 9/21/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface taskVC : UIViewController

- (IBAction) nextClicked: (id)sender;

@property (retain, nonatomic) IBOutlet UIView *displayArea;
@property (retain, nonatomic) IBOutlet UIButton *button;

@end
