//
//  HRAppletUtilities.h
//  HReader
//
//  Created by Caleb Davenport on 8/15/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRAppletUtilities : NSObject

/*
 
 
 
 */
+ (NSURL *)URLForAppletContainer:(NSString *)identifier;


/*
 
 
 
 */
+ (NSData *)encryptData:(NSData *)object identifier:(NSString *)identifier;
+ (NSData *)encryptPropertyListObject:(id)object identifier:(NSString *)identifier;

/*
 
 
 
 */
+ (NSData *)encryptString:(NSData *)object identifier:(NSString *)identifier;
+ (NSData *)encryptArray:(NSArray *)object identifier:(NSString *)identifier;
+ (NSData *)encryptDictionary:(NSDictionary *)object identifier:(NSString *)identifier;

/*
 
 
 
 */
+ (NSData *)decryptData:(NSData *)data identifier:(NSString *)identifier;
+ (id)decryptPropertyListObject:(NSData *)data identifier:(NSString *)identifier;

/*
 
 
 
 */
+ (NSString *)decryptString:(NSData *)data identifier:(NSString *)identifier;
+ (NSArray *)decryptArray:(NSData *)data identifier:(NSString *)identifier;
+ (NSDictionary *)decryptDictionary:(NSData *)data identifier:(NSString *)identifier;

@end
