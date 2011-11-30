//
//  HRRootViewController.m
//  HReader
//
//  Created by Marshall Huss on 11/30/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRRootViewController.h"
#import "HRPatientSummarySplitViewController.h"

@interface HRRootViewController ()
- (void)setupPatientLabelWithText:(NSString *)text;
- (void)setLogo;
- (void)setScrollViewShadow;
- (void)setupSegmentedControl;
@end

@implementation HRRootViewController

@synthesize scrollView          = __scrollView;
@synthesize contentView         = __contentView;
@synthesize segmentedControl    = __segmentedControl;


- (void)dealloc {
    [__scrollView release];
    [__contentView release];
    [__segmentedControl release];
    
    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeObserver:self forKeyPath:@"title"];
    }];
    
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        HRPatientSummarySplitViewController *patientSummaryViewController = [[[HRPatientSummarySplitViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        patientSummaryViewController.title = @"Summary";
        patientSummaryViewController.view.backgroundColor = [UIColor greenColor];
        [self addChildViewController:patientSummaryViewController];
        
        HRPatientSummarySplitViewController *patientSummaryViewController2 = [[[HRPatientSummarySplitViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        patientSummaryViewController2.title = @"Timeline";
        patientSummaryViewController2.view.backgroundColor = [UIColor redColor];
        [self addChildViewController:patientSummaryViewController2];
        
        HRPatientSummarySplitViewController *patientSummaryViewController3 = [[[HRPatientSummarySplitViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        patientSummaryViewController3.title = @"Messages (0)";
        patientSummaryViewController3.view.backgroundColor = [UIColor yellowColor];
        [self addChildViewController:patientSummaryViewController3];
        
        HRPatientSummarySplitViewController *patientSummaryViewController4 = [[[HRPatientSummarySplitViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        patientSummaryViewController4.title = @"Doctors";
        patientSummaryViewController4.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        [self addChildViewController:patientSummaryViewController4];
        
        [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj addObserver:self forKeyPath:@"title" options:0 context:0];
        }];
        
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setScrollViewShadow];
    [self setupPatientLabelWithText:@"Last Updated: 05 May by Joseph Yang, M.D. (Columbia Pediatric Associates)"];
    [self setLogo];
    

    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[HRSplitViewController class]]) {
            HRSplitViewController *splitViewController = (HRSplitViewController *)obj;
            [self.scrollView addSubview:splitViewController.view];
            [self.contentView addSubview:splitViewController.detailView];
        }
    }];
    
    [self setupSegmentedControl];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.scrollView = nil;
    self.contentView = nil;
    self.segmentedControl = nil;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    CGSize viewSize = self.view.bounds.size;
    self.scrollView.contentSize = CGSizeMake(viewSize.width * [self.childViewControllers count], self.scrollView.bounds.size.height);
    
    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[HRSplitViewController class]]) {
            HRSplitViewController *splitViewController = (HRSplitViewController *)obj;

            splitViewController.view.frame = CGRectMake(viewSize.width * idx, 0, viewSize.width, self.scrollView.bounds.size.height);
        
            splitViewController.detailView.frame = CGRectMake(viewSize.width * idx, 0, viewSize.width, self.contentView.bounds.size.height);
            
        }
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGSize size = self.contentView.bounds.size;
    
    [self.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)obj;
            view.frame = CGRectMake(self.scrollView.contentOffset.x * -1.0 + size.width * idx, 0.0, size.width, size.height);
        }
    }];
    
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.segmentedControl.selectedSegmentIndex = self.scrollView.contentOffset.x / self.scrollView.bounds.size.width;
}


#pragma mark - Private methods

- (void)setupPatientLabelWithText:(NSString *)text {
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                          target:nil 
                                                                          action:nil];
    UILabel *lastUpdatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 11.0f, self.view.frame.size.width, 21.0f)];
    lastUpdatedLabel.text = text;
    lastUpdatedLabel.textAlignment = UITextAlignmentCenter;
    lastUpdatedLabel.shadowColor = [UIColor whiteColor];
    lastUpdatedLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    lastUpdatedLabel.font = [UIFont boldSystemFontOfSize:14.0];
    lastUpdatedLabel.textColor = [UIColor grayColor];
    lastUpdatedLabel.backgroundColor = [UIColor clearColor];
    UIBarButtonItem *lastUpdated = [[UIBarButtonItem alloc] initWithCustomView:lastUpdatedLabel];
    self.toolbarItems = [NSArray arrayWithObjects:flex, lastUpdated, flex, nil];
}

- (void)setLogo {
    UIImage *logo = [UIImage imageNamed:@"hReader_Logo_34x150"];
    UIImageView *logoView = [[UIImageView alloc] initWithImage:logo];
    logoView.frame = CGRectMake(5, 5, 150, 34);
    [self.navigationController.navigationBar addSubview:logoView];
    [logoView release];
}

- (void)setScrollViewShadow {
    CALayer *layer = self.scrollView.layer;
    layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    layer.shadowOpacity = 0.5;
    layer.shadowOffset = CGSizeMake(0, 3);
    layer.masksToBounds = NO;
    [self.view bringSubviewToFront:self.scrollView];    
}

- (void)setupSegmentedControl {
    
    NSArray *segmentedItems = [self.childViewControllers valueForKey:@"title"];

    self.segmentedControl = [[[UISegmentedControl alloc] initWithItems:segmentedItems] autorelease];
    self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    
    NSInteger count = [segmentedItems count];
    for (int i = 0; i < count; i++) {
        [self.segmentedControl setWidth:600/count forSegmentAtIndex:i];
    }
    
    self.segmentedControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = self.segmentedControl;
    
    [self.segmentedControl addTarget:self action:@selector(segmentSelected) forControlEvents:UIControlEventValueChanged];    
}

- (void)segmentSelected {
    [self.scrollView setContentOffset:CGPointMake(self.segmentedControl.selectedSegmentIndex * self.scrollView.bounds.size.width, 0) animated:YES];
}

#pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"]) {
        // update segments
        UIViewController *viewController = (UIViewController *)object;
        [self.segmentedControl setTitle:viewController.title 
                      forSegmentAtIndex:[self.childViewControllers indexOfObject:viewController]];
    }
}

@end
