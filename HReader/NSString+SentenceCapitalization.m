//
//  NSString+SentenceCapitalization.m
//  HReader
//
//  Created by Caleb Davenport on 5/4/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "NSString+SentenceCapitalization.h"

@implementation NSString (SentenceCapitalization)

- (NSString *)sentenceCapitalizedString {
    NSString *value = [self lowercaseString];
    if ([value length]) {
        NSRange range = NSMakeRange(0, 1);
        NSString *firstCharacter = [value substringWithRange:range];
        firstCharacter = [firstCharacter uppercaseString];
        value = [value stringByReplacingCharactersInRange:range withString:firstCharacter];
    }
    return value;
}

@end
