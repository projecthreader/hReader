//
//  HRKeychainManager.m
//  HReader
//
//  Created by Caleb Davenport on 3/22/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRKeychainManager.h"

#import "SSKeychain.h"

static NSString * const HRKeychainUUID = @"KeychainUUID";
static NSString * const HRKeychainService = @"org.mitre.hreader";
static NSString * const HRKeychainPasscodeAccount = @"passcode";
static NSString * const HRKeychainSecurityQuestionsAccount = @"security_questions";
static NSString * const HRKeychainSecurityAnswersAccount = @"security_answers";

@interface HRKeychainManager ()

+ (NSString *)accountNameWithType:(NSString *)type;

@end

@implementation HRKeychainManager

#pragma mark - other class methods

+ (void)initialize {
    if (self == [HRKeychainManager class]) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:HRKeychainUUID] == nil) {
            CFUUIDRef UUIDRef = CFUUIDCreate(kCFAllocatorDefault);
            NSString *UUID = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, UUIDRef);
            CFRelease(UUIDRef);
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults
             setObject:UUID
             forKey:HRKeychainUUID];
            [defaults synchronize];
        }
        
    }
}

+ (NSString *)accountNameWithType:(NSString *)type {
    NSString *UUID = [[NSUserDefaults standardUserDefaults] objectForKey:HRKeychainUUID];
    return [UUID stringByAppendingPathExtension:type];
}

#pragma mark - passcode

+ (void)setPasscode:(NSString *)code {
    [SSKeychain
     setPassword:code
     forService:HRKeychainService
     account:[self accountNameWithType:HRKeychainPasscodeAccount]];
}

+ (BOOL)isPasscodeValid:(NSString *)code {
    NSString *keychain = [SSKeychain
                          passwordForService:HRKeychainService
                          account:[self accountNameWithType:HRKeychainPasscodeAccount]];
    return [code isEqualToString:keychain];
}

+ (BOOL)isPasscodeSet {
    NSString *keychain = [SSKeychain
                          passwordForService:HRKeychainService
                          account:[self accountNameWithType:HRKeychainPasscodeAccount]];
    return (keychain != nil);
}

#pragma mark - security questions

+ (void)setSecurityQuestions:(NSArray *)questions answers:(NSArray *)answers {
    
    // save questions
    NSData *questionsData = [NSJSONSerialization dataWithJSONObject:questions options:0 error:nil];
    [SSKeychain
     setPasswordData:questionsData
     forService:HRKeychainService
     account:[self accountNameWithType:HRKeychainSecurityQuestionsAccount]];
    
    // save answers
    NSData *answersData = [NSJSONSerialization dataWithJSONObject:answers options:0 error:nil];
    [SSKeychain
     setPasswordData:answersData
     forService:HRKeychainService
     account:[self accountNameWithType:HRKeychainSecurityAnswersAccount]];
    
}

+ (NSArray *)securityQuestions {
    NSData *data = [SSKeychain
                    passwordDataForService:HRKeychainService
                    account:[self accountNameWithType:HRKeychainSecurityQuestionsAccount]];
    if ([data length] > 0) {
        return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else {
        return nil;
    }
}

+ (BOOL)areAnswersForSecurityQuestionsValid:(NSArray *)answers {
    NSData *keychainData = [SSKeychain
                            passwordDataForService:HRKeychainService
                            account:[self accountNameWithType:HRKeychainSecurityAnswersAccount]];
    NSArray *keychainAnswers = [NSJSONSerialization JSONObjectWithData:keychainData options:0 error:nil];
    return ([keychainAnswers isEqualToArray:answers]);
}

@end
