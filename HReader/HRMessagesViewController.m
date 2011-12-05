//
//  HRMessagesViewController.m
//  HReader
//
//  Created by Marshall Huss on 12/2/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRMessagesViewController.h"

@interface HRMessagesViewController ()
- (void)setHeaderViewShadow;
@end

@implementation HRMessagesViewController

@synthesize patientImageShadowView      = __patientImageShadowView;
@synthesize patientImageView            = __patientImageView;
@synthesize datesArray                  = __datesArray;
@synthesize scrollView                  = __scrollView;
@synthesize messageContentView          = __messageContentView;
@synthesize patientView                 = __patientView;

- (void)dealloc {
    [__patientImageShadowView release];
    [__patientImageView release];
    [__datesArray release];
    [__scrollView release];
    [__messageContentView release];
    [__patientView release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Messages (0)";
        self.datesArray = [NSArray arrayWithObjects:@"7 Apr. 2011", @"28 Mar. 2011", @"27 Mar. 2011", @"17 Jan. 2011", @"13 Dec. 2010", @"5 Dec. 2010", @"28 Oct. 2010", @"23 Oct. 2010", nil];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [HRConfig setShadowForView:self.patientImageShadowView borderForView:self.patientImageView];
    
    self.scrollView.contentSize = self.messageContentView.bounds.size;
    [self.scrollView addSubview:self.messageContentView];
    
    [self setHeaderViewShadow];
    

    
}

- (void)viewDidUnload {
    [self setPatientImageShadowView:nil];
    [self setPatientImageView:nil];
    
    [self setScrollView:nil];
    [self setMessageContentView:nil];
    [self setPatientView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


#pragma mark - UITableViewDelegate



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.datesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MessageCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }

    cell.textLabel.text = [self.datesArray objectAtIndex:indexPath.row];

    return cell;
}

#pragma mark - Private methods

- (void)setHeaderViewShadow {
    CALayer *layer = self.patientView.layer;
    layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    layer.shadowOpacity = 0.5;
    layer.shadowOffset = CGSizeMake(0, 3);
    layer.masksToBounds = NO;
    [self.view bringSubviewToFront:self.patientView];    
}

@end
