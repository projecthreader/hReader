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
static NSString * const HRSharedKeySecurityAnswersKeychainAccount = @"shared_key_security_answers";

// static variables

static NSString *_temporaryPasscode = nil;
static NSString *_temporaryKey = nil;
static NSArray *_temporaryQuestions = nil;
static NSArray *_temporaryAnswers = nil;

// function prototypes

static NSData * HRCryptoManagerHashString(NSString *string);
static NSData * HRCryptoManagerHashData(NSData *data);
static NSData * HRCryptoManagerEncrypt_private(NSString *key, NSData *data);
static NSData * HRCryptoManagerDecrypt_private(NSString *key, NSData *data);
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

static NSData * HRCryptoManagerEncrypt_private(NSString *key, NSData *data) {
    
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

static NSData * HRCryptoManagerDecrypt_private(NSString *key, NSData *data) {
    
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

void HRCryptoManagerTest(void) {
    NSData *message = [@"test message" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *key = @"my test key";
    NSData *cipher = HRCryptoManagerEncrypt_private(key, message);
    NSData *result = HRCryptoManagerDecrypt_private(key, cipher);
    NSCAssert([message isEqualToData:result], @"The original and transformed messages must be the same");
    NSCAssert(![message isEqualToData:cipher], @"The original message and cipher text must not be the same");
}

#pragma mark - public methods

BOOL HRCryptoManagerHasPasscode(void) {
    return ([SSKeychain passwordDataForService:HRKeychainService account:HRPasscodeKeychainAccount] != nil);
}

BOOL HRCryptoManagerHasSecurityQuestions(void) {
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
    NSData *one = HRCryptoManagerEncrypt_private(_temporaryPasscode, key);
    [SSKeychain setPasswordData:one forService:HRKeychainService account:HRSharedKeyPasscodeKeychainAccount];
    
    // store shared key encrypted with clear answers to security questions
    NSData *two = HRCryptoManagerEncrypt_private([_temporaryAnswers componentsJoinedByString:@""], key);
    [SSKeychain setPasswordData:two forService:HRKeychainService account:HRSharedKeySecurityAnswersKeychainAccount];
    
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

BOOL HRCryptoManagerUnlockWithPasscode(NSString *passcode) {
    NSData *encryptedKey = [SSKeychain passwordDataForService:HRKeychainService account:HRSharedKeyPasscodeKeychainAccount];
    NSData *decryptedKey = HRCryptoManagerDecrypt_private(passcode, encryptedKey);
    if (decryptedKey) {
        _temporaryKey = [[NSString alloc] initWithData:decryptedKey encoding:NSUTF8StringEncoding];
        return YES;
    }
    return NO;
}

BOOL HRCryptoManagerUnlockWithAnswersForSecurityQuestions(NSArray *answers) {
    NSData *encryptedKey = [SSKeychain passwordDataForService:HRKeychainService account:HRSharedKeySecurityAnswersKeychainAccount];
    NSData *decryptedKey = HRCryptoManagerDecrypt_private([answers componentsJoinedByString:@""], encryptedKey);
    if (decryptedKey) {
        _temporaryKey = [[NSString alloc] initWithData:decryptedKey encoding:NSUTF8StringEncoding];
        return YES;
    }
    return NO;
}

BOOL HRCryptoManagerIsUnlocked(void) {
    return (_temporaryKey != nil);
}

NSData * HRCryptoManagerKeychainItemData(NSString *service, NSString *account) {
    NSCAssert(_temporaryKey, @"Decryption cannot be performed at this time");
    NSData *value = [SSKeychain passwordDataForService:service account:account];
    return HRCryptoManagerDecrypt_private(_temporaryKey, value);
}

NSString * HRCryptoManagerKeychainItemString(NSString *service, NSString *account) {
    NSData *value = HRCryptoManagerKeychainItemData(service, account);
    return [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
}

void HRCryptoManagerSetKeychainItemData(NSString *service, NSString *account, NSData *value) {
    NSCAssert(_temporaryKey, @"Decryption cannot be performed at this time");
    NSData *encrypted = HRCryptoManagerEncrypt_private(_temporaryKey, value);
    [SSKeychain setPasswordData:encrypted forService:service account:account];
}

void HRCryptoManagerSetKeychainItemString(NSString *service, NSString *account, NSString *value) {
    NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
    HRCryptoManagerSetKeychainItemData(service, account, valueData);
}

NSArray * HRCryptoManagerSecurityQuestions(void) {
    NSData *questions = [SSKeychain passwordDataForService:HRKeychainService account:HRSecurityQuestionsKeychainAccount];
    return [NSJSONSerialization JSONObjectWithData:questions options:0 error:nil];
}

@implementation HRCryptoManager

@end
