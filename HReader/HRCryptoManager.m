//
//  HRCryptoManager.m
//  HReader
//
//  Created by Caleb Davenport on 5/31/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

#import "HRCryptoManager.h"

// function prototypes

static inline NSData * HRCryptoManagerHash(NSString *string);
static inline NSData * HRCryptoManagerEncrypt(NSString *key, NSData *data);
static inline NSData * HRCryptoManagerDecrypt(NSString *key, NSData *data);
static inline void HRCryptoManagerTest(void);

// function definitions

static inline NSData * HRCryptoManagerHash(NSString *string) {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char md[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512([data bytes], [data length], md);
    return [NSData dataWithBytes:md length:CC_SHA512_DIGEST_LENGTH];
}

static inline NSData * HRCryptoManagerEncrypt(NSString *key, NSData *data) {
    
    // get key bytes
    NSRange key_range = NSMakeRange(0, kCCKeySizeAES256);
    NSData *key_data = [HRCryptoManagerHash(key) subdataWithRange:key_range];
    
    // get initialization vector
    NSString *iv_string = [[NSProcessInfo processInfo] globallyUniqueString];
    NSRange iv_range = NSMakeRange(0, kCCBlockSizeAES128);
    NSData *iv_data = [HRCryptoManagerHash(iv_string) subdataWithRange:iv_range];
    
    // determine total needed space
    size_t length;
    CCCryptorStatus status = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                     [key_data bytes], [key_data length],
                                     [iv_data bytes],
                                     [data bytes], [data length],
                                     NULL, 0,
                                     &length);
    if (status != kCCBufferTooSmall) { return nil; }
    
    // create buffer
    void *buffer = malloc(length);
    if (buffer == nil) { return nil; }
    memcpy(buffer, [iv_data bytes], [iv_data length]);
    
    // perform encryption
    status = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                     [key_data bytes], [key_data length],
                     [iv_data bytes],
                     [data bytes], [data length],
                     (buffer + [iv_data length]), length,
                     &length);
    
    // cleanup and return
    if (status == kCCSuccess) {
        free(buffer);
        return [NSData dataWithBytes:buffer length:(length + [iv_data length])];
    }
    else {
        free(buffer);
        NSLog(@"%s %d", __PRETTY_FUNCTION__, status);
        return nil;
    }
    
}

static inline NSData * HRCryptoManagerDecrypt(NSString *key, NSData *data) {
    
    // get key bytes
    NSRange key_range = NSMakeRange(0, kCCKeySizeAES256);
    NSData *key_data = [HRCryptoManagerHash(key) subdataWithRange:key_range];
    
    // determine total needed space
    size_t length;
    CCCryptorStatus status = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                     [key_data bytes], [key_data length],
                                     [data bytes],
                                     [data bytes] + kCCBlockSizeAES128, [data length] - kCCBlockSizeAES128,
                                     NULL, 0,
                                     &length);
    
    // create buffer
    void *buffer = malloc(length);
    if (buffer == nil) { return nil; }
    
    // perform decryption
    status = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                     [key_data bytes], [key_data length],
                     [data bytes],
                     [data bytes] + kCCBlockSizeAES128, [data length] - kCCBlockSizeAES128,
                     buffer, length,
                     &length);
    
    // cleanup and return
    if (status == kCCSuccess) {
        free(buffer);
        return [NSData dataWithBytes:buffer length:length];
    }
    else {
        free(buffer);
        NSLog(@"%s %d", __PRETTY_FUNCTION__, status);
        return nil;
    }
    
}

void HRCryptoManagerTest(void) {
    NSData *message = [@"test message" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *key = @"my test key";
    NSData *cipher = HRCryptoManagerEncrypt(key, message);
    NSData *result = HRCryptoManagerDecrypt(key, cipher);
    NSCAssert([message isEqualToData:result], @"The original and transformed messages must be the same");
    NSCAssert(![message isEqualToData:cipher], @"The original message and cipher text must not be the same");
}

@implementation HRCryptoManager

@end
