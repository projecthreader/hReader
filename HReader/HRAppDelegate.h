//
//  HRAppDelegate.h
//  HReader
//
//  Created by Marshall Huss on 11/14/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HRPrivacyViewController;
@class GCPINViewController;

@interface HRAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) HRPrivacyViewController *privacyViewController;

- (void)setAppearanceProxies;
- (void)showPrivacyWarning;
- (void)loadTestFlight;
- (void)setupPrivacyView;
- (GCPINViewController *)pinCodeViewController;

@end
