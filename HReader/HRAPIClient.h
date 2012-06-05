//
//  HRAPIClient.h
//  HReader
//
//  Created by Caleb Davenport on 5/30/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRAPIClient : NSObject

/*
 
 Set the host name (or IP address) of the RHEx server.
 
 */
+ (HRAPIClient *)clientWithHost:(NSString *)host;

/*
 
 
 
 */
+ (NSArray *)accounts;

/*
 
 
 
 */
- (void)patientFeed:(void (^) (NSArray *patients))completion;

/*
 
 
 
 */
- (void)JSONForPatientWithIdentifier:(NSString *)identifier finishBlock:(void (^) (NSDictionary *payload))block;
- (void)JSONForPatientWithIdentifier:(NSString *)identifier startBlock:(void (^) (void))startBlock finishBlock:(void (^) (NSDictionary *payload))finishBlock;

@end
