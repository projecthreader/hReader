//
//  HRAPIClient.h
//  HReader
//
//  Created by Caleb Davenport on 5/30/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRMEntry.h"

@interface HRAPIClient : NSObject

/*
 
 Decode the given query string into a set of parameters.
 
 */
+ (NSDictionary *)parametersFromQueryString:(NSString *)string;

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
 imediately and notifes the caller of progress using the `startBlock` and
 `finishBlock` parameters.
 
 `startBlock` simply notifies the caller that the operation is about to begin.
 
 `finishBlock` accepts a dictionary that represents the patient payload. This
 will be `nil` should an error occur.
 
 Both blocks will be executed on the main queue.
 
 */
- (void)JSONForPatientWithIdentifier:(NSString *)identifier
                          startBlock:(void (^) (void))startBlock
                         finishBlock:(void (^) (NSDictionary *payload))finishBlock;

/*
 
 Fetch a given patient payload from the receiver. This method waits for the
 response to come back so do not call this on the main thread.
 
 */
- (NSDictionary *)JSONForPatientWithIdentifier:(NSString *)identifier;

//Pushes new attribute to server
//attributeDictionary must have author, category, text(value). 
//Returns true if the attribute was successfully pushed/put
-(BOOL)pushAttribute:(NSDictionary *)attributeDictionary withType:(NSString *)attributeType ToEntry: (HRMEntry *)entry ForPatientWithIdentifier:(NSString *)identifier;

@end
