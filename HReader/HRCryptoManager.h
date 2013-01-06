//
//  HRCryptoManager.h
//  HReader
//
//  Created by Caleb Davenport on 5/31/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/*
 
 Adds an encrypted persistent store to the given NSPersistentStoreCoordinator.
 The store is encrypted with the applicatioin's master encryption key. This
 may only be called with the app is unlocked.
 
 */
NSPersistentStore *HRCryptoManagerAddEncryptedStoreToCoordinator(NSPersistentStoreCoordinator *coordinator,
                                                                 NSString *configuration,
                                                                 NSURL *URL,
                                                                 NSDictionary *options,
                                                                 NSError **error);

/*
 
 NOTE: All of the below functions are analogous to those seen in
 `IMSCryptoManager.h`. It would be best to use those functions from now on,
 especially since these functions simply pass through to similar functions in
 `IMSCryptoManager.h`.
 
 */
NSData * HRCryptoManagerDecryptData(NSData *data);
NSData * HRCryptoManagerEncryptData(NSData *data);
NSData * HRCryptoManagerEncryptDataWithKey(NSData *data, NSString *key);
NSData * HRCryptoManagerDecryptDataWithKey(NSData *data, NSString *key);
NSData *HRCryptoManagerHashString(NSString *string);
NSData *HRCryptoManagerHashData(NSData *data);
NSData * HRCryptoManagerKeychainItemData(NSString *service, NSString *account);
NSString * HRCryptoManagerKeychainItemString(NSString *service, NSString *account);
void HRCryptoManagerSetKeychainItemData(NSString *service, NSString *account, NSData *value);
void HRCryptoManagerSetKeychainItemString(NSString *service, NSString *account, NSString *value);
BOOL HRCryptoManagerHasPasscode(void);
BOOL HRCryptoManagerHasSecurityQuestions(void);
void HRCryptoManagerStoreTemporaryPasscode(NSString *code);
void HRCryptoManagerStoreTemporarySecurityQuestionsAndAnswers(NSArray *questions, NSArray *answers);
void HRCryptoManagerFinalize(void);
void HRCryptoManagerPurge(void);
BOOL HRCryptoManagerUnlockWithPasscode(NSString *passcode);
BOOL HRCryptoManagerUnlockWithAnswersForSecurityQuestions(NSArray *answers);
BOOL HRCryptoManagerIsUnlocked(void);
void HRCryptoManagerUpdatePasscode(NSString *passcode);
void HRCryptoManagerUpdateSecurityQuestionsAndAnswers(NSArray *questions, NSArray *answers);
NSArray * HRCryptoManagerSecurityQuestions(void);
