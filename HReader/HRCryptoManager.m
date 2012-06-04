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

#import "SSKeychain.h"

// keychain keys

static NSString * const HRKeychainService = @"org.mitre.hreader.security";
static NSString * const HRPasscodeKeychainAccount = @"passcode";
static NSString * const HRSharedKeyPasscodeKeychainAccount = @"shared_key_passcode";
static NSString * const HRSecurityQuestionsKeychainAccount = @"security_questions";
static NSString * const HRSecurityAnswersKeychainAccount = @"security_answers";
static NSString * const HRSharedKeySecurityAnswersKeychain = @"shared_key_security_answers";

// static variables

static NSString *_temporaryPasscode = nil;
static NSString *_temporaryKey = nil;
static NSArray *_temporaryQuestions = nil;
static NSArray *_temporaryAnswers = nil;

// function prototypes

static NSData * HRCryptoManagerHashString(NSString *string);
static NSData * HRCryptoManagerHashData(NSData *data);
static NSData * HRCryptoManagerEncrypt(NSString *key, NSData *data);
static NSData * HRCryptoManagerDecrypt(NSString *key, NSData *data);
static void HRCryptoManagerTest(void);

// function definitions

static NSData * HRCryptoManagerHashString(NSString *string) {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return HRCryptoManagerHashData(data);
}

static NSData * HRCryptoManagerHashData(NSData *data) {
    void *buffer = malloc(CC_SHA512_DIGEST_LENGTH);
    if (buffer == nil) { return nil; }
    CC_SHA512([data bytes], [data length], buffer);
    return [NSData dataWithBytesNoCopy:buffer length:CC_SHA512_DIGEST_LENGTH];
}

static NSData * HRCryptoManagerEncrypt(NSString *key, NSData *data) {
    
    // get key bytes
    NSRange key_range = NSMakeRange(0, kCCKeySizeAES256);
    NSData *key_data = [HRCryptoManagerHashString(key) subdataWithRange:key_range];
    
    // get initialization vector
    NSString *iv_string = [[NSProcessInfo processInfo] globallyUniqueString];
    NSRange iv_range = NSMakeRange(0, kCCBlockSizeAES128);
    NSData *iv_data = [HRCryptoManagerHashString(iv_string) subdataWithRange:iv_range];
    
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
    void *buffer = malloc(length + [iv_data length]);
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
        return [NSData dataWithBytesNoCopy:buffer length:(length + [iv_data length])];
    }
    else {
        free(buffer);
#if DEBUG
        NSLog(@"%s %d", __PRETTY_FUNCTION__, status);
#endif
        return nil;
    }
    
}

static NSData * HRCryptoManagerDecrypt(NSString *key, NSData *data) {
    
    // get key bytes
    NSRange key_range = NSMakeRange(0, kCCKeySizeAES256);
    NSData *key_data = [HRCryptoManagerHashString(key) subdataWithRange:key_range];
    
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
        return [NSData dataWithBytesNoCopy:buffer length:length];
    }
    else {
        free(buffer);
#if DEBUG
        NSLog(@"%s %d", __PRETTY_FUNCTION__, status);
#endif
        return nil;
    }
    
}

BOOL HRCryptoManagerHasPasscode(void) {
    return ([SSKeychain passwordDataForService:HRKeychainService account:HRPasscodeKeychainAccount] != nil);
}

BOOL HRCyproManagerHasSecurityQuestions(void) {
    return ([SSKeychain passwordDataForService:HRKeychainService account:HRSecurityQuestionsKeychainAccount] != nil &&
            [SSKeychain passwordDataForService:HRKeychainService account:HRSecurityAnswersKeychainAccount]);
}

void HRCryptoManagerStoreTemporarySecurityQuestionsAndAnswers(NSArray *questions, NSArray *answers) {
    NSCAssert([questions count] == [answers count], @"The number of questions and answers must be equal");
    _temporaryQuestions = [questions copy];
    _temporaryAnswers = [answers copy];
}

void HRCryptoManagerStoreTemporaryPasscode(NSString *code) {
    _temporaryPasscode = [code copy];
}

void HRCryptoManagerFinalize(void) {
    
    // generate shared key
    _temporaryKey = [[NSProcessInfo processInfo] globallyUniqueString];
    NSData *key = [_temporaryKey dataUsingEncoding:NSUTF8StringEncoding];
    
    // store hashed passcode
    NSData *passcode = HRCryptoManagerHashString(_temporaryPasscode);
    [SSKeychain setPasswordData:passcode forService:HRKeychainService account:HRPasscodeKeychainAccount];
    
    // store hashed answers to security questions as
    NSData *answers = [NSJSONSerialization dataWithJSONObject:_temporaryAnswers options:0 error:nil];
    answers = HRCryptoManagerHashData(answers);
    [SSKeychain setPasswordData:answers forService:HRKeychainService account:HRSecurityAnswersKeychainAccount];
    
    // store clear security questions
    NSData *questions = [NSJSONSerialization dataWithJSONObject:_temporaryQuestions options:0 error:nil];
    [SSKeychain setPasswordData:questions forService:HRKeychainService account:HRSecurityQuestionsKeychainAccount];
    
    // store shared key encrypted with clear passcode
    NSData *one = HRCryptoManagerEncrypt(_temporaryPasscode, key);
    [SSKeychain setPasswordData:one forService:HRKeychainService account:HRSharedKeyPasscodeKeychainAccount];
    
    // store shared key encrypted with clear answers to security questions
    NSData *two = HRCryptoManagerEncrypt([_temporaryAnswers componentsJoinedByString:@""], key);
    [SSKeychain setPasswordData:two forService:HRKeychainService account:HRSharedKeySecurityAnswersKeychain];
    
    // cleanup
    _temporaryAnswers = nil;
    _temporaryQuestions = nil;
    _temporaryPasscode = nil;
    
}

void HRCryptoManagerPurge(void) {
    _temporaryAnswers = nil;
    _temporaryQuestions = nil;
    _temporaryPasscode = nil;
    _temporaryKey = nil;
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
