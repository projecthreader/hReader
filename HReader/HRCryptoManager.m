//
//  HRCryptoManager.m
//  HReader
//
//  Created by Caleb Davenport on 5/31/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <SecureFoundation/SecureFoundation.h>

#import "HRCryptoManager.h"

#import "CMDEncryptedSQLiteStore.h"

// keychain keys

static NSString * const HRCryptoManagerKeychainService = @"org.hreader.security.3";
static NSString * const HRCryptoManagerSaltKeychainAccount = @"salt";
static NSString * const HRDatabaseKeyKeychainAccount = @"database_key";

#pragma mark - generate salt

NSData *HRCryptoManagerSalt(void) {
    static NSData *salt;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        salt = [IMSKeychain
                passwordDataForService:HRCryptoManagerKeychainService
                account:HRCryptoManagerSaltKeychainAccount];
        if (salt == nil) {
            salt = IMSCryptoUtilsPseudoRandomData(kCCKeySizeAES256);
            [IMSKeychain
             setPasswordData:salt
             forService:HRCryptoManagerKeychainService
             account:HRCryptoManagerSaltKeychainAccount];
        }
    });
    return salt;
}

#pragma mark - pass through to crypto manager

NSData * HRCryptoManagerHashString(NSString *string) {
    return IMSHashPlistObject_SHA256(string);
}

NSData * HRCryptoManagerHashData(NSData *data) {
    return IMSHashData_SHA256(data);
}

BOOL HRCryptoManagerHasPasscode(void) {
    return IMSCryptoManagerHasPasscode();
}

BOOL HRCryptoManagerHasSecurityQuestions(void) {
    return IMSCryptoManagerHasSecurityQuestionsAndAnswers();
}

void HRCryptoManagerStoreTemporarySecurityQuestionsAndAnswers(NSArray *questions, NSArray *answers) {
    IMSCryptoManagerStoreTemporarySecurityQuestionsAndAnswers(questions, answers);
}

void HRCryptoManagerStoreTemporaryPasscode(NSString *code) {
    IMSCryptoManagerStoreTemporaryPasscode(code);
}

void HRCryptoManagerFinalize(void) {
    IMSCryptoManagerFinalize();
}

void HRCryptoManagerPurge(void) {
    IMSCryptoManagerPurge();
}

BOOL HRCryptoManagerUnlockWithPasscode(NSString *passcode) {
    return IMSCryptoManagerUnlockWithPasscode(passcode);
}

BOOL HRCryptoManagerUnlockWithAnswersForSecurityQuestions(NSArray *answers) {
    return IMSCryptoManagerUnlockWithAnswersForSecurityQuestions(answers);
}

BOOL HRCryptoManagerIsUnlocked(void) {
    return !IMSCryptoManagerIsLocked();
}

NSData * HRCryptoManagerDecryptData(NSData *data) {
    return IMSCryptoManagerDecryptData(data);
}

NSData * HRCryptoManagerEncryptData(NSData *data) {
    return IMSCryptoManagerEncryptData(data);
}

void HRCryptoManagerUpdatePasscode(NSString *passcode) {
    IMSCryptoManagerUpdatePasscode(passcode);
}

void HRCryptoManagerUpdateSecurityQuestionsAndAnswers(NSArray *questions, NSArray *answers) {
    IMSCryptoManagerUpdateSecurityQuestionsAndAnswers(questions, answers);
}

NSArray * HRCryptoManagerSecurityQuestions(void) {
    return IMSCryptoManagerSecurityQuestions();
}

void HRCryptoManagerSetKeychainItemString(NSString *service, NSString *account, NSString *value) {
    [IMSKeychain setSecurePassword:value forService:service account:account];
}

void HRCryptoManagerSetKeychainItemData(NSString *service, NSString *account, NSData *value) {
    [IMSKeychain setSecurePasswordData:value forService:service account:account];
}

NSString * HRCryptoManagerKeychainItemString(NSString *service, NSString *account) {
    return [IMSKeychain securePasswordForService:service account:account];
}

NSData * HRCryptoManagerKeychainItemData(NSString *service, NSString *account) {
    return [IMSKeychain securePasswordDataForService:service account:account];
}

NSData * HRCryptoManagerEncryptDataWithKey(NSData *data, NSString *key) {
    NSData *salt = HRCryptoManagerSalt();
    NSData *keyData = IMSCryptoUtilsDeriveKey([key dataUsingEncoding:NSUTF8StringEncoding], kCCKeySizeAES256, salt);
    return IMSCryptoUtilsEncryptData(data, keyData);
}

NSData * HRCryptoManagerDecryptDataWithKey(NSData *data, NSString *key) {
    NSData *salt = HRCryptoManagerSalt();
    NSData *keyData = IMSCryptoUtilsDeriveKey([key dataUsingEncoding:NSUTF8StringEncoding], kCCKeySizeAES256, salt);
    return IMSCryptoUtilsDecryptData(data, keyData);
}

#pragma mark - core data encryption

NSPersistentStore *HRCryptoManagerAddEncryptedStoreToCoordinator(NSPersistentStoreCoordinator *coordinator,
                                                                 NSString *configuration,
                                                                 NSURL *URL,
                                                                 NSDictionary *options,
                                                                 NSError **error) {
#define ENCRYPTED_STORE YES
    if (HRCryptoManagerIsUnlocked()) {
        NSString *key = HRCryptoManagerKeychainItemString(HRCryptoManagerKeychainService, HRDatabaseKeyKeychainAccount);
        if (key == nil) {
            key = [[NSProcessInfo processInfo] globallyUniqueString];
            HRCryptoManagerSetKeychainItemString(HRCryptoManagerKeychainService, HRDatabaseKeyKeychainAccount, key);
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
