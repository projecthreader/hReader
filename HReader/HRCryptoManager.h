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
BOOL HRCryptoManagerHasPasscode(void);

/*
 
 
 
 */
BOOL HRCyproManagerHasSecurityQuestions(void);

/*
 
 
 
 */
void HRCryptoManagerStoreTemporaryPasscode(NSString *code);

/*
 
 
 
 */
void HRCryptoManagerStoreTemporarySecurityQuestionsAndAnswers(NSArray *questions, NSArray *answers);

/*
 
 
 
 */
void HRCryptoManagerFinalize(void);

/*
 
 
 
 */
void HRCryptoManagerPurge(void);

//void HRCryptoManagerStoreTempo

@interface HRCryptoManager : NSObject

@end
