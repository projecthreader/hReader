//
//  HRAppDelegate.h
//  HReader
//
//  Created by Marshall Huss on 11/14/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PINSecurityQuestionsViewController.h"
#import "PINCodeViewController.h"

@interface HRAppDelegate : UIResponder

<
UIApplicationDelegate,
PINSecurityQuestionsViewControllerDelegate,
PINCodeViewControllerDelegate
>

@property (strong, nonatomic) UIWindow *window;

/*
 
 Access the application-wide core data managed object context. This context
 is created using the main queue concurrency type.
 
 */
+ (NSManagedObjectContext *)managedObjectContext;

// if you call this i will kill you
- (void)dismissModalViewController;

@end
