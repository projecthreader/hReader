//
//  HRPasscodeManager.m
//  HReader
//
//  Created by Marshall Huss on 12/16/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "HRPasscodeManager.h"

@implementation HRPasscodeManager

+ (BOOL)passcodeIsSet {
    
//    NSError *error = nil;
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"passcode_check"];        
//    NSLog(@"Path: %@", path);
//    NSDictionary *attributes = [NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey];
//    
//    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
//    [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
//    [[NSFileManager defaultManager] setAttributes:attributes ofItemAtPath:path error:&error];
//    
//    NSLog(@"Protected Data Available: %i", [[UIApplication sharedApplication] isProtectedDataAvailable]);
//    NSLog(@"File Protection Error: %@", error);
//    if (error) {
//        return NO;
//    } else {
//        return YES;
//    }
    
//    NSString *foobar = @"foobar";
//    NSData *data = [foobar dataUsingEncoding:NSUTF8StringEncoding];
//    NSError *error = nil;
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"passcode_check"];    
//    [data writeToFile:path options:NSDataWritingFileProtectionComplete error:&error];
//    NSLog(@"%@", error);
//    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
//    if (error) {
//        return YES;
//    } else {
//        return NO;
//    }

//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"passcode_check"];
//    
//    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSFileProtectionComplete];
//    BOOL passcodeOn = [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:attributes];
//    
//    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    
//    return passcodeOn;
    return NO;
}

@end
