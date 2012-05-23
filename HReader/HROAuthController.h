//
//  HROAuthController.h
//  HReader
//
//  Created by Caleb Davenport on 5/23/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HROAuthController : UIViewController <UIWebViewDelegate>

+ (void)getRequestTokens;

@end
