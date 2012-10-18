//
//  HRAppletUtilities.h
//  HReader
//
//  Created by Caleb Davenport on 8/15/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 
 Methods to assist with common applet operations. The identifier that is
 accepted in each of these methods should be the same identifier you provide
 in hReaderApplets.plist.
 
 */
@interface HRAppletUtilities : NSObject

/*
 
 Get a URL to the sandox for the applet with the given identifier.
 
 */
+ (NSURL *)URLForAppletContainer:(NSString *)identifier;


/*
 
 Encrypt general binary data and proprty list objects.
 
 */
+ (NSData *)encryptData:(NSData *)object identifier:(NSString *)identifier;
+ (NSData *)encryptPropertyListObject:(id)object identifier:(NSString *)identifier;

/*
 
 Helper methods for encrypting typed property list objects.
 
 */
+ (NSData *)encryptString:(NSData *)object identifier:(NSString *)identifier;
+ (NSData *)encryptArray:(NSArray *)object identifier:(NSString *)identifier;
+ (NSData *)encryptDictionary:(NSDictionary *)object identifier:(NSString *)identifier;

/*
 
 Decrypt general binary data and property list objects.
 
 */
+ (NSData *)decryptData:(NSData *)data identifier:(NSString *)identifier;
+ (id)decryptPropertyListObject:(NSData *)data identifier:(NSString *)identifier;

/*
 
 Helper methods for decrypting typed property list objects.
 
 */
+ (NSString *)decryptString:(NSData *)data identifier:(NSString *)identifier;
+ (NSArray *)decryptArray:(NSData *)data identifier:(NSString *)identifier;
+ (NSDictionary *)decryptDictionary:(NSData *)data identifier:(NSString *)identifier;

@end
