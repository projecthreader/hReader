//
//  HRAppletUtilities.m
//  HReader
//
//  Created by Caleb Davenport on 8/15/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <objc/runtime.h>

#import "HRAppletUtilities.h"
#import "HRCryptoManager.h"

static NSString *HRAppletKeysKeychainService = @"org.mitre.hreader.applet-keys";

static NSCache *keyCache = nil;

@implementation HRAppletUtilities

+ (void)load {
    @autoreleasepool {
        
        // encryption
        {
            NSArray *methods = @[
                @"encryptString:identifier:",
                @"encryptArray:identifier:",
                @"encryptDictionary:identifier:"
            ];
            Method m = class_getClassMethod(self, @selector(encryptPropertyListObject:identifier:));
            IMP i = method_getImplementation(m);
            [methods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                method_setImplementation(class_getClassMethod(self, NSSelectorFromString(obj)), i);
            }];
        }
        
        // decryption
        {
            NSArray *methods = @[
                @"decryptString:identifier:",
                @"decryptArray:identifier:",
                @"decryptDictionary:identifier:"
            ];
            Method m = class_getClassMethod(self, @selector(decryptPropertyListObject:identifier:));
            IMP i = method_getImplementation(m);
            [methods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                method_setImplementation(class_getClassMethod(self, NSSelectorFromString(obj)), i);
            }];
        }
        
    }
}

+ (void)initialize {
    if (self == [HRAppletUtilities class]) {
        keyCache = [[NSCache alloc] init];
    }
}

+ (NSString *)keyForAppletWithIdentifier:(NSString *)identifier {
    NSString *key = [keyCache objectForKey:identifier];
    if (key == nil) {
        key = HRCryptoManagerKeychainItemString(HRAppletKeysKeychainService, identifier);
    }
    if (key == nil) {
        key = [[NSProcessInfo processInfo] globallyUniqueString];
        HRCryptoManagerSetKeychainItemString(HRAppletKeysKeychainService, identifier, key);
        [keyCache setObject:key forKey:identifier];
    }
    return key;
}

+ (NSURL *)URLForAppletContainer:(NSString *)identifier {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *folders = [manager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
    NSURL *URL = [folders objectAtIndex:0];
    URL = [URL URLByAppendingPathComponent:@"Applets"];
    // TODO: hash identifier so it isn't necessarily predictable
    URL = [URL URLByAppendingPathComponent:identifier];
    
    // create folders
    NSError *error = nil;
    if (![manager createDirectoryAtURL:URL withIntermediateDirectories:YES attributes:nil error:&error]) {
        if ([error code] != NSFileWriteFileExistsError) {
            return nil;
        }
    }
    
    // return
    return URL;
    
}

+ (NSData *)encryptData:(NSData *)object identifier:(NSString *)identifier {
    NSString *key = [self keyForAppletWithIdentifier:identifier];
    return HRCryptoManagerEncryptDataWithKey(object, key);
}

+ (NSData *)encryptPropertyListObject:(id)object identifier:(NSString *)identifier {
    CFDataRef data = CFPropertyListCreateData(kCFAllocatorDefault,
                                              (__bridge CFPropertyListRef)object,
                                              kCFPropertyListBinaryFormat_v1_0,
                                              0,
                                              NULL);
    return [self encryptData:(__bridge_transfer NSData *)data identifier:identifier];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wall"
+ (NSData *)encryptString:(NSData *)object identifier:(NSString *)identifier {}
+ (NSData *)encryptArray:(NSArray *)object identifier:(NSString *)identifier {}
+ (NSData *)encryptDictionary:(NSDictionary *)object identifier:(NSString *)identifier {}
#pragma clang diagnostic pop

+ (NSData *)decryptData:(NSData *)data identifier:(NSString *)identifier {
    NSString *key = [self keyForAppletWithIdentifier:identifier];
    return HRCryptoManagerDecryptDataWithKey(data, key);
}

+ (id)decryptPropertyListObject:(NSData *)data identifier:(NSString *)identifier {
    NSData *decrypted = [self decryptData:data identifier:identifier];
    CFPropertyListRef plist = CFPropertyListCreateWithData(kCFAllocatorDefault,
                                                           (__bridge CFDataRef)decrypted,
                                                           0,
                                                           NULL,
                                                           NULL);
    return (__bridge_transfer id)plist;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wall"
+ (NSString *)decryptString:(NSData *)data identifier:(NSString *)identifier {}
+ (NSArray *)decryptArray:(NSData *)data identifier:(NSString *)identifier {}
+ (NSDictionary *)decryptDictionary:(NSData *)data identifier:(NSString *)identifier {}
#pragma clang diagnostic pop

@end
