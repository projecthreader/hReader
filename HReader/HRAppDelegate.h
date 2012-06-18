//
//  HRAppDelegate.h
//  HReader
//
//  Created by Marshall Huss on 11/14/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HRSecurityQuestionsViewController.h"

@interface HRAppDelegate : UIResponder

<
UIApplicationDelegate,
HRSecurityQuestionsViewControllerDelegate
>

@property (strong, nonatomic) UIWindow *window;

/*
 
 Access the application-wide core data persistent store coordinator.
 
 */
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

/*
 
 Access the application-wide core data managed object context. This context
 is created using the main queue concurrency type.
 
 */
+ (NSManagedObjectContext *)managedObjectContext;

@end
