//
//  HRManagedObject.h
//  HReader
//
//  Created by Caleb Davenport on 2/8/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCManagedObject;
@class NSManagedObjectContext;

@protocol HRManagedObject <NSObject>

+ (id)instanceWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context;

@end
