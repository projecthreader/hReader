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

#import "CMDEncryptedSQLiteStore.h"

// keychain keys

static NSString * const HRKeychainService                           = @"org.hreader.security.2";
static NSString * const HRSecurityQuestionsKeychainAccount          = @"security_questions";
static NSString * const HRSecurityAnswersKeychainAccount            = @"security_answers";
static NSString * const HRPasscodeKeychainAccount                   = @"passcode";
static NSString * const HRSharedKeyPasscodeKeychainAccount          = @"shared_key_passcode";
static NSString * const HRSharedKeySecurityAnswersKeychainAccount   = @"shared_key_security_answers";
static NSString * const HRDatabaseKeyKeychainAccount                = @"database_key";
static NSString * const HRKeychainIdentifierFlag                    = @"org.hreader.security.flag";
static const int HRSecurityQuestionsXORKey                          = 156;

// static variables

static NSString *_temporaryPasscode = nil;
static NSString *_temporaryKey = nil;
static NSArray *_temporaryQuestions = nil;
static NSArray *_temporaryAnswers = nil;

#pragma mark - encrypt and decrypt data

NSData * HRCryptoManagerDecryptData(NSData *data) {
    return HRCryptoManagerDecryptDataWithKey(data, _temporaryKey);
}
NSData * HRCryptoManagerEncryptData(NSData *data) {
    return HRCryptoManagerEncryptDataWithKey(data, _temporaryKey);
}
NSData * HRCryptoManagerEncryptDataWithKey(NSData *data, NSString *key) {
    if (data && key) {
        
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
        }
        
    }
    return nil;
}
NSData * HRCryptoManagerDecryptDataWithKey(NSData *data, NSString *key) {
    if (data && key) {
        
        // get key bytes
        NSRange key_range = NSMakeRange(0, kCCKeySizeAES256);
        NSData *key_data = [HRCryptoManagerHashString(key) subdataWithRange:key_range];
        
        // determine total needed space
        size_t length;
        CCCryptorStatus status;
        CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
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
        }
        
    }
    return nil;
}

#pragma mark - perform hash on given objects

NSData * HRCryptoManagerHashString(NSString *string) {
    if (string) {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        return HRCryptoManagerHashData(data);
    }
    return nil;
}
NSData * HRCryptoManagerHashData(NSData *data) {
    if (data) {
        void *buffer = malloc(CC_SHA512_DIGEST_LENGTH);
        if (buffer == nil) { return nil; }
        CC_SHA512([data bytes], [data length], buffer);
        return [NSData dataWithBytesNoCopy:buffer length:CC_SHA512_DIGEST_LENGTH];
    }
    return nil;
}

#pragma mark - set and get keychain data

void HRCryptoManagerSetKeychainItemString(NSString *service, NSString *account, NSString *value) {
    if (value) {
        NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
        HRCryptoManagerSetKeychainItemData(service, account, valueData);
    }
}
void HRCryptoManagerSetKeychainItemData(NSString *service, NSString *account, NSData *value) {
    NSData *encrypted = HRCryptoManagerEncryptData(value);
    [SSKeychain setPasswordData:encrypted forService:service account:account];
}
NSString * HRCryptoManagerKeychainItemString(NSString *service, NSString *account) {
    NSData *value = HRCryptoManagerKeychainItemData(service, account);
    if (value) {
        return [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
    }
    return nil;
}
NSData * HRCryptoManagerKeychainItemData(NSString *service, NSString *account) {
    NSData *data = [SSKeychain passwordDataForService:service account:account];
    return HRCryptoManagerDecryptData(data);
}

#pragma mark - check state of stored encryption resources

BOOL HRCryptoManagerHasPasscode(void) {
    return ([SSKeychain passwordDataForService:HRKeychainService account:HRSharedKeyPasscodeKeychainAccount] &&
            [SSKeychain passwordDataForService:HRKeychainService account:HRPasscodeKeychainAccount]);
}
BOOL HRCryptoManagerHasSecurityQuestions(void) {
    return ([SSKeychain passwordDataForService:HRKeychainService account:HRSecurityQuestionsKeychainAccount] &&
            [SSKeychain passwordDataForService:HRKeychainService account:HRSharedKeySecurityAnswersKeychainAccount] &&
            [SSKeychain passwordDataForService:HRKeychainService account:HRSecurityAnswersKeychainAccount]);
}

#pragma mark - setup app encryption

void HRCryptoManagerStoreTemporarySecurityQuestionsAndAnswers(NSArray *questions, NSArray *answers) {
    NSCAssert([questions count] > 0 && [questions count] == [answers count], @"The number of questions and answers must be equal");
    _temporaryQuestions = [questions copy];
    _temporaryAnswers = [answers copy];
}

void HRCryptoManagerStoreTemporaryPasscode(NSString *code) {
    NSCAssert([code length], @"The passcode must not be blank");
    _temporaryPasscode = [code copy];
}

void HRCryptoManagerFinalize(void) {
    NSCAssert(_temporaryAnswers && _temporaryQuestions && _temporaryPasscode, @"HRCryptoManagerFinalize() was called before all encryption setup was done");
    
    // generate shared key
    _temporaryKey = [[NSProcessInfo processInfo] globallyUniqueString];
    
    // store passcode
    HRCryptoManagerUpdatePasscode(_temporaryPasscode);
    
    // store answers for security questions
    HRCryptoManagerUpdateSecurityQuestionsAndAnswers(_temporaryQuestions, _temporaryAnswers);
    
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

#pragma mark - handle unlock state of the app

BOOL HRCryptoManagerUnlockWithPasscode(NSString *passcode) {
    NSCAssert(passcode, @"The passcode must not be nil");
    NSData *encryptedIdentifierData = [SSKeychain passwordDataForService:HRKeychainService account:HRPasscodeKeychainAccount];
    NSData *identifierData = HRCryptoManagerDecryptDataWithKey(encryptedIdentifierData, passcode);
    NSString *identifier = [[NSString alloc] initWithData:identifierData encoding:NSUTF8StringEncoding];
    if ([identifier isEqualToString:HRKeychainIdentifierFlag]) {
        NSData *encryptedKey = [SSKeychain passwordDataForService:HRKeychainService account:HRSharedKeyPasscodeKeychainAccount];
        NSData *decryptedKey = HRCryptoManagerDecryptDataWithKey(encryptedKey, passcode);
        if (decryptedKey) {
            _temporaryKey = [[NSString alloc] initWithData:decryptedKey encoding:NSUTF8StringEncoding];
            return YES;
        }
    }
    return NO;
}

BOOL HRCryptoManagerUnlockWithAnswersForSecurityQuestions(NSArray *answers) {
    NSCAssert(answers, @"The answers must not be nil");
    NSString *answersString = [answers componentsJoinedByString:@""];
    NSData *encryptedIdentifierData = [SSKeychain passwordDataForService:HRKeychainService account:HRSecurityAnswersKeychainAccount];
    NSData *identifierData = HRCryptoManagerDecryptDataWithKey(encryptedIdentifierData, answersString);
    NSString *identifier = [[NSString alloc] initWithData:identifierData encoding:NSUTF8StringEncoding];
    if ([identifier isEqualToString:HRKeychainIdentifierFlag]) {
        NSData *encryptedKey = [SSKeychain passwordDataForService:HRKeychainService account:HRSharedKeySecurityAnswersKeychainAccount];
        NSData *decryptedKey = HRCryptoManagerDecryptDataWithKey(encryptedKey, [answers componentsJoinedByString:@""]);
        if (decryptedKey) {
            _temporaryKey = [[NSString alloc] initWithData:decryptedKey encoding:NSUTF8StringEncoding];
            return YES;
        }
    }
    return NO;
}

BOOL HRCryptoManagerIsUnlocked(void) {
    return (_temporaryKey != nil);
}

#pragma mark - update encryption resources

void HRCryptoManagerUpdatePasscode(NSString *passcode) {
    NSCAssert(passcode, @"The passcode must not be nil");
    if (_temporaryKey) {
        
        // write encrypted shared key
        NSData *keyData = [_temporaryKey dataUsingEncoding:NSUTF8StringEncoding];
        NSData *encryptedKeyData = HRCryptoManagerEncryptDataWithKey(keyData, passcode);
        [SSKeychain setPasswordData:encryptedKeyData forService:HRKeychainService account:HRSharedKeyPasscodeKeychainAccount];
        
        // write encrypted identifier
        NSData *identifierData = [HRKeychainIdentifierFlag dataUsingEncoding:NSUTF8StringEncoding];
        NSData *encryptedIdentifierData = HRCryptoManagerEncryptDataWithKey(identifierData, passcode);
        [SSKeychain setPasswordData:encryptedIdentifierData forService:HRKeychainService account:HRPasscodeKeychainAccount];
        
    }
}

void HRCryptoManagerUpdateSecurityQuestionsAndAnswers(NSArray *questions, NSArray *answers) {
    NSCAssert(questions, @"The questions must not be nil");
    NSCAssert(answers, @"The answers must not be nil");
    if (_temporaryKey) {
        NSString *answersString = [answers componentsJoinedByString:@""];
        
        // write clear questions
        NSMutableData *questionsData = [[NSJSONSerialization dataWithJSONObject:questions options:0 error:nil] mutableCopy];
        NSUInteger length = [questionsData length];
        char *bytes = [questionsData mutableBytes];
        XOR(HRSecurityQuestionsXORKey, bytes, length);
        [SSKeychain setPasswordData:questionsData forService:HRKeychainService account:HRSecurityQuestionsKeychainAccount];
        
        // write  encrypted shared key
        NSData *keyData = [_temporaryKey dataUsingEncoding:NSUTF8StringEncoding];
        NSData *encryptedKeyData = HRCryptoManagerEncryptDataWithKey(keyData, answersString);
        [SSKeychain setPasswordData:encryptedKeyData forService:HRKeychainService account:HRSharedKeySecurityAnswersKeychainAccount];
        
        // write encrypted identifier
        NSData *identifierData = [HRKeychainIdentifierFlag dataUsingEncoding:NSUTF8StringEncoding];
        NSData *encryptedIdentifierData = HRCryptoManagerEncryptDataWithKey(identifierData, answersString);
        [SSKeychain setPasswordData:encryptedIdentifierData forService:HRKeychainService account:HRSecurityAnswersKeychainAccount];
        
    }
}

#pragma mark - get security questions

NSArray * HRCryptoManagerSecurityQuestions(void) {
    NSMutableData *questions = [[SSKeychain passwordDataForService:HRKeychainService account:HRSecurityQuestionsKeychainAccount] mutableCopy];
    NSUInteger length = [questions length];
    char *bytes = [questions mutableBytes];
    XOR(HRSecurityQuestionsXORKey, bytes, length);
    return [NSJSONSerialization JSONObjectWithData:questions options:0 error:nil];
}

#pragma mark - core data encryption

NSPersistentStore *HRCryptoManagerAddEncryptedStoreToCoordinator(NSPersistentStoreCoordinator *coordinator,
                                                                 NSString *configuration,
                                                                 NSURL *URL,
                                                                 NSDictionary *options,
                                                                 NSError **error) {
    static BOOL ENCRYPTED_STORE = YES;
    if (HRCryptoManagerIsUnlocked()) {
        NSString *key = HRCryptoManagerKeychainItemString(HRKeychainService, HRDatabaseKeyKeychainAccount);
        if (key == nil) {
            key = [[NSProcessInfo processInfo] globallyUniqueString];
            HRCryptoManagerSetKeychainItemString(HRKeychainService, HRDatabaseKeyKeychainAccount, key);
        }
        NSMutableDictionary *mutableOptions = [options mutableCopy];
        [mutableOptions setObject:key forKey:CMDEncryptedSQLiteStorePassphraseKey];
        return [coordinator
                addPersistentStoreWithType:(ENCRYPTED_STORE ? CMDEncryptedSQLiteStoreType : NSSQLiteStoreType)
                configuration:configuration
                URL:(ENCRYPTED_STORE ? [URL URLByAppendingPathExtension:@"encrypted"] : URL)
                options:mutableOptions
                error:error];
    }
    return nil;
}
