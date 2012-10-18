//
//  HRTimelineViewController.h
//  HReader
//
//  Created by Marshall Huss on 12/2/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "HRContentViewController.h"

@interface HRTimelineViewController : HRContentViewController <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *scopeSelector;

- (IBAction)scopeSelectorValueDidChange:(UISegmentedControl *)sender;

@end
