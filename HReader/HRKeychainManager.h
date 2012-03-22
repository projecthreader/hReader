//
//  HRKeychainManager.h
//  HReader
//
//  Created by Caleb Davenport on 3/22/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRKeychainManager : NSObject

// PIN code
+ (void)setPasscode:(NSString *)code;
+ (BOOL)isPasscodeValid:(NSString *)code;
+ (BOOL)isPasscodeSet;

// security questions
+ (void)setSecurityQuestions:(NSArray *)questions answers:(NSArray *)answers;
+ (NSArray *)securityQuestions;
+ (BOOL)areAnswersForSecurityQuestionsValid:(NSArray *)answers;

@end
