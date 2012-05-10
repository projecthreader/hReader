//
//  HRAppletTile.m
//  HReader
//
//  Created by Caleb Davenport on 4/10/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRAppletTile.h"
#import "HRMPatient.h"

@interface HRAppletTile () {
@private
    HRMPatient * __strong __patient;
    NSDictionary * __strong __userInfo;
}

- (void)commonInit;

@end

@implementation HRAppletTile

#pragma mark - class methods

+ (id)tileWithPatient:(HRMPatient *)patient userInfo:(NSDictionary *)userInfo {
    HRAppletTile *tile = nil;
    
    // load the tile
    NSString *nibName = [userInfo objectForKey:@"nib_name"];
    if (nibName == nil) {
        nibName = NSStringFromClass(self);
    }
    NSURL *nibURL = [[NSBundle mainBundle] URLForResource:nibName withExtension:@"nib"];
    NSData *nibData = [NSData dataWithContentsOfURL:nibURL];
    if (nibData) {
//        NSLog(@"Loading %@.nib for %@", nibName, NSStringFromClass(self));
        UINib *nib = [UINib nibWithData:nibData bundle:nil];
        tile = [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    }
    else {
//        NSLog(@"Loading %@ with no nib", NSStringFromClass(self));
        tile = [[self alloc] init];
    }
    
    // configure
    tile->__patient = patient;
    tile->__userInfo = userInfo;
    [tile tileDidLoad];
    
    return tile;
}

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIApplicationDidEnterBackgroundNotification
     object:nil];
}

- (void)commonInit {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationDidEnterBackground)
     name:UIApplicationDidEnterBackgroundNotification
     object:nil];
}

- (HRMPatient *)patient {
    return __patient;
}

- (NSDictionary *)userInfo {
    return __userInfo;
}

# pragma mark - tile lifecycle

- (void)tileDidLoad {
    
}

#pragma mark - gestures

- (void)didReceiveTap:(UIViewController *)sender inRect:(CGRect)rect {
    
}

#pragma mark - notifications

- (void)applicationDidEnterBackground {
    
}

@end
