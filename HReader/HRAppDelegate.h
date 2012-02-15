//
//  HRAppDelegate.h
//  HReader
//
//  Created by Marshall Huss on 11/14/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// access core data stores
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
+ (NSManagedObjectContext *)managedObjectContext;

@end
