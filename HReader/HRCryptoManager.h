//
//  HRCryptoManager.h
//  HReader
//
//  Created by Caleb Davenport on 5/31/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 
 
 
 */
#define XOR(_key, _input, _length) for (size_t _i = 0; _i < _length; _i++) { _input[_i] ^= _key; }

/*
 
 
 
 */
BOOL HRCryptoManagerHasPasscode(void);

/*
 
 
 
 */
BOOL HRCryptoManagerHasSecurityQuestions(void);

/*
 
 Store values that will be used to drive encryption with these methods. Data
 stored by these methods will only be kept in memory until 
 `HRCryptoManagerFinalize` is called.
 
 */
void HRCryptoManagerStoreTemporaryPasscode(NSString *code);
void HRCryptoManagerStoreTemporarySecurityQuestionsAndAnswers(NSArray *questions, NSArray *answers);

/*
 
 Finalize the encryption setup process and save all valid attributes to the
 keychain. This method generates the shared encryption key, stores all
 relevant resources to the keychain, and purges any values from memory that
 are not necessary to keep.
 
 */
void HRCryptoManagerFinalize(void);

/*
 
 Call this method any time the application looses focus. This causes all cached
 encryption resources to be purged from memory. Any future calls 
 
 */
void HRCryptoManagerPurge(void);

/*
 
 Unlock the application given the appropriate data. Each of these functions
 returns whether the app has been successfully unlocked.
 
 */
BOOL HRCryptoManagerUnlockWithPasscode(NSString *passcode);
BOOL HRCryptoManagerUnlockWithAnswersForSecurityQuestions(NSArray *answers);
BOOL HRCryptoManagerIsUnlocked(void);

/*
 
 Set new authentication information. These may only be called when the app is
 unlocked.
 
 */
void HRCryptoManagerUpdatePasscode(NSString *passcode);
void HRCryptoManagerUpdateSecurityQuestionsAndAnswers(NSArray *questions, NSArray *answers);

/*
 
 
 
 */
NSData * HRCryptoManagerKeychainItemData(NSString *service, NSString *account);
NSString * HRCryptoManagerKeychainItemString(NSString *service, NSString *account);
void HRCryptoManagerSetKeychainItemData(NSString *service, NSString *account, NSData *value);
void HRCryptoManagerSetKeychainItemString(NSString *service, NSString *account, NSString *value);

/*
 
 Access the stored security questions.
 
 */
NSArray * HRCryptoManagerSecurityQuestions(void);

/*
 
 
 
 */
NSData * HRCryptoManagerDecryptData(NSData *data);
NSData * HRCryptoManagerEncryptData(NSData *data);
NSData * HRCryptoManagerEncryptDataWithKey(NSData *data, NSString *key);
NSData * HRCryptoManagerDecryptDataWithKey(NSData *data, NSString *key);

/*
 
 
 
 */
NSData *HRCryptoManagerHashString(NSString *string);
NSData *HRCryptoManagerHashData(NSData *data);
