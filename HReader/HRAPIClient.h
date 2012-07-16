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
 
 Get a list of all hosts that have authenticated accounts stored locally.
 
 */
+ (NSArray *)hosts;

/*
 
 Request the patient feed from the receiver. This method returns imediatly and
 notifies the caller upon completion using the completion block.
 
 The completion accepts an array of dictionaries each having two keys: id and
 name. Should an error occur, `patients` will be nil. It will be executed on
 the main queue.
 
 */
- (void)patientFeed:(void (^) (NSArray *patients))completion;

/*
 
 Fetch a given patient payload from the receiver. This method returns
 imediately and notifes the caller upon completion using the completion block
 and optionally on start with the start block.
 
 `finishBlock` accepts a dictionary that represents the patient payload. This
 will be `nil` should an error occur.
 
 `startBlock` simply notifies the caller that the operation is about to begin.
 
 Both blocks will be executed on the main queue.
 
 */
- (void)JSONForPatientWithIdentifier:(NSString *)identifier finishBlock:(void (^) (NSDictionary *payload))block;
- (void)JSONForPatientWithIdentifier:(NSString *)identifier startBlock:(void (^) (void))startBlock finishBlock:(void (^) (NSDictionary *payload))finishBlock;

@end
