//
//  HRMessagesViewController.m
//  HReader
//
//  Created by Marshall Huss on 12/2/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRMessagesViewController.h"
#import "HRPatientSwipeViewController.h"
#import "HRMessage.h"

@interface HRMessagesViewController ()
- (void)setHeaderViewShadow;
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
@synthesize dateFormatter               = __dateFormatter;

- (void)dealloc {
    [__patientImageShadowView release];
    [__patientImageView release];
    [__messagesArray release];
    [__scrollView release];
    [__messageContentView release];
    [__patientView release];
    [__dateFormatter release];
    [__subjectLabel release];
    [__bodyLabel release];
    [__messageView release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        self.dateFormatter.dateFormat = @"M LLL. YYYY";
        
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        [messages addObject:[HRMessage messageWithSubject:@"Johnny Smith's Health Record" body:@"Johnny Smith's Health Record was updated on 07 July, 2011 by Candy Remandy, M.D. at Columbia Pediatric Associates.\n\n\tThe following sections of the Health Record were changed in this update:\n\n\tMedications\n\n\tVital Signs\n\n\tProblems\n\nIf you have any questions or concerns, please contact Columbia Pediatrics Associates at 410.555.8752" date:[HRConfig dateForString:@"20110407"]]];
        [messages addObject:[HRMessage messageWithSubject:@"Appointment Reminder" body:@"Dear Valued Patient,\n\n\nThis messages is to remind you that you have an appointment scheduled for Monday, March 21, 2011.  Please call 508-555-1212 to confirm appointment.\n\nThank You" date:[HRConfig dateForString:@"20110328"]]];
        [messages addObject:[HRMessage messageWithSubject:@"Appointment Confirmed" body:@"Dear Valued Patient,\n\n\nThis messages is to confim your appointment scheduled for Monday, March 21, 2011.\n\nThank You" date:[HRConfig dateForString:@"20110327"]]];
        [messages addObject:[HRMessage messageWithSubject:@"Yearly Checkup Reminder" body:@"Dear Valued Patient,\n\n\nThis messages is to remind you that it is that time of the year again for your yearly physical. \n\nPlease email or call 508-555-1212 to schedule an appointment.\n\nThank You" date:[HRConfig dateForString:@"20110117"]]];
        [messages addObject:[HRMessage messageWithSubject:@"Lab Results" body:@"Dear Valued Patient,\n\n\nYour lab results are complete, please connect to this <LINK> to download and view. \n\nPlease email or call 508-555-1212 with any questions or issues with download.\n\nThank You" date:[HRConfig dateForString:@"20111213"]]];
        [messages addObject:[HRMessage messageWithSubject:@"Johnny Smith's Message 6" body:@"Message 6 body here" date:[HRConfig dateForString:@"20111205"]]];
        [messages addObject:[HRMessage messageWithSubject:@"Johnny Smith's Message 7" body:@"Message 7 body here" date:[HRConfig dateForString:@"20101028"]]];
        

        self.messagesArray = messages;
        [messages release];
        
        self.title = [NSString stringWithFormat:@"Messages (%lu)", [self.messagesArray count]];
        
        HRPatientSwipeViewController *patientSwipeViewController = [[HRPatientSwipeViewController alloc] initWithNibName:nil bundle:nil];
        [self addChildViewController:patientSwipeViewController];
        patientSwipeViewController.patientsArray = [HRConfig patients];
        [patientSwipeViewController release];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    HRPatientSwipeViewController *patientSwipeViewController = (HRPatientSwipeViewController *)[self.childViewControllers objectAtIndex:0];
    [self.patientView addSubview:patientSwipeViewController.view];
    
    self.scrollView.contentSize = self.messageContentView.bounds.size;
    [self.scrollView addSubview:self.messageContentView];
    
    [self setHeaderViewShadow];   

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HRMessage *message = [self.messagesArray objectAtIndex:indexPath.row];
    
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"View Message (%@)", message.subject]];
    
    self.subjectLabel.text = message.subject;
    self.bodyLabel.text = message.body;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messagesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MessageCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    HRMessage *message = [self.messagesArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [self.dateFormatter stringFromDate:message.received];

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
