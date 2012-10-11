//
//  HRMessagesViewController.m
//  HReader
//
//  Created by Marshall Huss on 12/2/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRMessagesViewController.h"
#import "HRMPatient.h"
#import "HRPanelViewController.h"
#import "HRPeoplePickerViewController.h"

@interface HRMessagesViewController ()
- (void)reloadData;
- (void)setHeaderViewShadow;
- (void)patientDidChange:(NSNotification *)notification;
@end

@implementation HRMessagesViewController

@synthesize patientImageShadowView      = __patientImageShadowView;
@synthesize patientImageView            = __patientImageView;
@synthesize messagesArray               = __messagesArray;
@synthesize scrollView                  = __scrollView;
@synthesize messageContentView          = __messageContentView;
@synthesize subjectLabel                = __subjectLabel;
@synthesize bodyLabel                   = __bodyLabel;
@synthesize messageView                 = __messageView;
@synthesize patientView                 = __patientView;
@synthesize tableView                   = __tableView;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:HRPatientDidChangeNotification
     object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Messages";
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(patientDidChange:)
         name:HRPatientDidChangeNotification
         object:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [self reloadData];
        });
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // load patient swipe
//    HRPatientSwipeControl *swipe = [HRPatientSwipeControl
//                                    controlWithOwner:self
//                                    options:nil 
//                                    target:self
//                                    action:@selector(patientChanged:)];
//    [self.patientView addSubview:swipe];
    
    self.scrollView.contentSize = self.messageContentView.bounds.size;
    [self.scrollView addSubview:self.messageContentView];
    
    [self setHeaderViewShadow];   
    
    [self patientDidChange:nil];
    
    CALayer *layer = self.patientImageView.layer;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOpacity = 0.35;
    layer.shadowOffset = CGSizeMake(0.0, 1.0);
    layer.shadowRadius = 5.0;
    layer.shouldRasterize = YES;
    layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    // swipe gesture
    {
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didReceiveRightSwipe:)];
        swipeGesture.numberOfTouchesRequired = 1;
        swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
        [self.patientImageView addGestureRecognizer:swipeGesture];
    }
    {
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didReceiveLeftSwipe:)];
        swipeGesture.numberOfTouchesRequired = 1;
        swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.patientImageView addGestureRecognizer:swipeGesture];
    }
}

- (void)viewDidUnload {
    self.patientImageShadowView = nil;
    self.patientImageView = nil;
    self.scrollView = nil;
    self.messageContentView = nil;
    self.patientView = nil;
    
    [self setSubjectLabel:nil];
    [self setBodyLabel:nil];
    [self setMessageView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *message = [self.messagesArray objectAtIndex:indexPath.row];
    self.subjectLabel.text = [message objectForKey:@"subject"];
    self.bodyLabel.text = [message objectForKey:@"body"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messagesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MessageCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSDictionary *message = [self.messagesArray objectAtIndex:indexPath.row];
    NSTimeInterval interval = [[message objectForKey:@"date"] doubleValue];
    cell.textLabel.text = [[NSDate dateWithTimeIntervalSince1970:interval] hr_mediumStyleDate];

    return cell;
}

#pragma mark - NSNotificationCenter

- (void)patientDidChange:(NSNotification *)sender {
    [self reloadData];
    [self.tableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - Private methods

- (void)reloadData {
    
    HRMPatient *patient = [(id)self.panelViewController.leftAccessoryViewController selectedPatient];
    self.patientImageView.image = [patient patientImage];
    
    self.messagesArray = [[patient valueForKeyPath:@"syntheticInfo.messages"] hr_sortedArrayUsingKey:@"date" ascending:NO];
    self.title = [NSString stringWithFormat:@"Messages (%lu)", (unsigned long)[self.messagesArray count]];
}

- (void)setHeaderViewShadow {
    CALayer *layer = self.patientView.layer;
    layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    layer.shadowOpacity = 0.5;
    layer.shadowOffset = CGSizeMake(0, 3);
    layer.masksToBounds = NO;
    [self.view bringSubviewToFront:self.patientView];    
}

#pragma mark - gestures

- (void)didReceiveLeftSwipe:(UISwipeGestureRecognizer *)swipe {
    if (swipe.state == UIGestureRecognizerStateRecognized) {
        [(id)self.panelViewController.leftAccessoryViewController selectNextPatient];
    }
}
- (void)didReceiveRightSwipe:(UISwipeGestureRecognizer *)swipe {
    if (swipe.state == UIGestureRecognizerStateRecognized) {
        [(id)self.panelViewController.leftAccessoryViewController selectPreviousPatient];
    }
}

@end
