//
//  HRTimelinePOSTURLProtocol.h
//  HReader
//
//  Created by Caleb Davenport on 11/5/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 
 Instances of this class answer `POST` requests from the timeline. They ignore
 all URLs that do not begin with `http://hreader.local/timeline.json`. This
 class will be registered with the URL loading system automatically when it
 is loaded.
 
 */
@interface HRTimelinePOSTURLProtocol : NSURLProtocol

@end
