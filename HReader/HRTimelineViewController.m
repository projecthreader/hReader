//
//  HRTimelineViewController.m
//  HReader
//
//  Created by Marshall Huss on 12/2/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#define HR_TIMELINE_XML 0
#define HR_TIMELINE_JSON !HR_TIMELINE_XML

#import <QuartzCore/QuartzCore.h>

#import "HRTimelineViewController.h"
#import "HRPatientSwipeControl.h"
#import "HRPeoplePickerViewController.h"
#import "HRAPIClient.h"

#import "SVPanelViewController.h"

#import "HRMPatient.h"

#import "DDXML.h"

@implementation HRTimelineViewController

#pragma mark - class methods

- (NSString *)viewName {
    NSInteger index = self.scopeSelector.selectedSegmentIndex;
    if (index == 0) {
        return @"decade.html";
    }
    else if (index == 1) {
        return @"year.html";
    }
    else if (index == 2) {
        return @"month.html";
    }
    else if (index == 3) {
        return @"week.html";
    }
    else if (index == 4) {
        return @"index.html";
    }
    return nil;
}

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.title = @"Timeline";
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(reloadData)
         name:HRPatientDidChangeNotification
         object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:HRPatientDidChangeNotification
     object:nil];
}

- (void)reloadData {
    if ([self isViewLoaded]) {
        
        // load patient
        HRMPatient *patient = [(id)self.panelViewController.leftAccessoryViewController selectedPatient];
        self.patientImageView.image = [patient patientImage];
        self.nameLabel.text = [patient.compositeName uppercaseString];
        NSURL *URL = nil;
        
#if HR_TIMELINE_XML
        URL = [[[NSFileManager defaultManager]
                URLsForDirectory:NSDocumentDirectory
                inDomains:NSUserDomainMask]
               lastObject];
        URL = [URL URLByAppendingPathComponent:@"hReader.xml"];
        NSString *XMLString = [[[patient timelineXMLPayload] XMLString] copy];
        NSData *XMLData = [XMLString dataUsingEncoding:NSUTF8StringEncoding];
        BOOL write = [XMLData
                      writeToURL:URL
                      options:(NSDataWritingAtomic | NSDataWritingFileProtectionComplete)
                      error:nil];
        NSAssert(write, @"The XML file could not be written");
        
        // load timeline
        URL = [[NSBundle mainBundle]
               URLForResource:@"hReader"
               withExtension:@"html"
               subdirectory:@"timeline/hReader"];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webView loadRequest:request];
#endif
#if HR_TIMELINE_JSON
        NSString *viewName = [self viewName];
        URL = [[NSBundle mainBundle]
               URLForResource:[viewName stringByDeletingPathExtension]
               withExtension:[viewName pathExtension]
               subdirectory:@"timeline-angular/app"];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webView loadRequest:request];
#endif
        
    }
}

- (IBAction)scopeSelectorValueDidChange:(UISegmentedControl *)sender {
    [self reloadData];
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // header view shadow
    CALayer *layer = self.headerView.layer;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOpacity = 0.35;
    layer.shadowOffset = CGSizeMake(0.0, 0.0);
    layer.shadowRadius = 5.0;
    layer.shouldRasterize = YES;
    layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [self.view bringSubviewToFront:self.headerView];
    
    // patient image shadow
    layer = self.patientImageView.superview.layer;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOpacity = 0.35;
    layer.shadowOffset = CGSizeMake(0.0, 1.0);
    layer.shadowRadius = 5.0;
    layer.shouldRasterize = YES;
    layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    // gestures
    {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(patientImageViewTap:)];
        gesture.numberOfTapsRequired = 1;
        gesture.numberOfTouchesRequired = 1;
        [self.patientImageView.superview addGestureRecognizer:gesture];
    }
    
    // reload
    [self reloadData];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - gestures

- (void)patientImageViewTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        [(id)self.panelViewController.leftAccessoryViewController selectNextPatient];
    }
}

@end
