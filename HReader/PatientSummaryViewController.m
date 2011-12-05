//
//  PatientSummaryViewController.m
//  HReader
//
//  Created by Marshall Huss on 11/15/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "PatientSummaryViewController.h"
#import "TimelineViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface PatientSummaryViewController ()
- (void)setPageCurlShadowForImageView:(UIImageView *)imageView;
@end

@implementation PatientSummaryViewController

@synthesize scrollView       = __scrollView;
@synthesize patientImageView = __patientImageView;
@synthesize patientNameLabel = __patientNameLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [__scrollView release];
    [__patientNameLabel release];
    [__patientImageView release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
/*
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(1024 * 2, 768 - 88);
    
    TimelineViewController *timelineViewController = [[TimelineViewController alloc] initWithNibName:nil bundle:nil];
    timelineViewController.view.frame = CGRectMake(1024, 0, 1024, 768 - 88);
    
    [self.scrollView addSubview:timelineViewController.view];

//    UILabel *timeline = [[UILabel alloc] initWithFrame:CGRectMake(200, 200, 50, 21)];
//    timeline.text = @"Timeline";
//    [self.scrollView addSubview:timeline];
    
    
//    self.view.backgroundColor = [UIColor hReaderTexture];
    self.patientImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.patientImageView.layer.borderWidth = 3.0;
    
    [self setPageCurlShadowForImageView:self.patientImageView];
    
    UIImage *logo = [UIImage imageNamed:@"hReader_Logo_34x150"];
    UIImageView *logoView = [[UIImageView alloc] initWithImage:logo];
    logoView.frame = CGRectMake(5, 5, 150, 34);
    [self.navigationController.navigationBar addSubview:logoView];
    [logoView release];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                          target:nil 
                                                                          action:nil];
    UILabel *lastUpdatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 11.0f, self.view.frame.size.width, 21.0f)];
    lastUpdatedLabel.text = @"Last Updated: 05 May by Joseph Yang, M.D. (Columbia Pediatric Associates)";
    lastUpdatedLabel.textAlignment = UITextAlignmentCenter;
    lastUpdatedLabel.shadowColor = [UIColor whiteColor];
    lastUpdatedLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    lastUpdatedLabel.font = [UIFont boldSystemFontOfSize:14.0];
    lastUpdatedLabel.textColor = [UIColor grayColor];
    lastUpdatedLabel.backgroundColor = [UIColor clearColor];
    UIBarButtonItem *lastUpdated = [[UIBarButtonItem alloc] initWithCustomView:lastUpdatedLabel];
    self.toolbarItems = [NSArray arrayWithObjects:flex, lastUpdated, flex, nil];
    
//    self.patientNameLabel.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
//    self.patientNameLabel.layer.shadowOpacity = 0.5;
//    self.patientNameLabel.layer.shadowOffset = CGSizeMake(0, 3);
//    self.patientNameLabel.layer.masksToBounds = NO;
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.scrollView = nil;
    self.patientImageView = nil;
    self.patientNameLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation ==  UIInterfaceOrientationLandscapeRight));
}

#pragma mark - UIScrollViewDelegate method

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
//    CGFloat pageWidth = self.scrollView.frame.size.width;
//    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
//    self.pageControl.currentPage = page;
}

#pragma mark - Private methods

- (void)setPageCurlShadowForImageView:(UIImageView *)imageView {
    imageView.layer.shadowColor = [[UIColor blackColor] CGColor];
    imageView.layer.shadowOpacity = 0.5f;
    imageView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    imageView.layer.shadowRadius = 5.0f;
    
//    CGSize size = imageView.bounds.size;
//    CGFloat curlFactor = 15.0f;
//    CGFloat shadowDepth = 5.0f;
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    [path moveToPoint:CGPointMake(0.0f, 0.0f)];
//    [path addLineToPoint:CGPointMake(size.width, 0.0f)];
//    [path addLineToPoint:CGPointMake(size.width, size.height + shadowDepth)];
//    
//    [path addCurveToPoint:CGPointMake(0.0f, size.height + shadowDepth)
//            controlPoint1:CGPointMake(size.width - curlFactor, size.height + shadowDepth - curlFactor)
//            controlPoint2:CGPointMake(curlFactor, size.height + shadowDepth - curlFactor)];
//    
//    imageView.layer.shadowPath = path.CGPath;
}

@end
