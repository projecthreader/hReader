//
//  PatientSummaryViewController.m
//  HReader
//
//  Created by Marshall Huss on 11/15/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "PatientSummaryViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface PatientSummaryViewController ()
- (void)setPageCurlShadowForImageView:(UIImageView *)imageView;
@end

@implementation PatientSummaryViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = TEXTURE_COLOR;
    self.patientImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.patientImageView.layer.borderWidth = 3.0;
    
    [self setPageCurlShadowForImageView:self.patientImageView];
    
    self.patientNameLabel.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    self.patientNameLabel.layer.shadowOpacity = 0.5;
    self.patientNameLabel.layer.shadowOffset = CGSizeMake(0, 3);
    self.patientNameLabel.layer.masksToBounds = NO;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.patientImageView = nil;
    self.patientNameLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Private methods

- (void)setPageCurlShadowForImageView:(UIImageView *)imageView {
    imageView.layer.shadowColor = [[UIColor blackColor] CGColor];
    imageView.layer.shadowOpacity = 0.5f;
    imageView.layer.shadowOffset = CGSizeMake(0.0f, 10.0f);
    imageView.layer.shadowRadius = 5.0f;
    
    CGSize size = imageView.bounds.size;
    CGFloat curlFactor = 15.0f;
    CGFloat shadowDepth = 5.0f;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0.0f, 0.0f)];
    [path addLineToPoint:CGPointMake(size.width, 0.0f)];
    [path addLineToPoint:CGPointMake(size.width, size.height + shadowDepth)];
    
    [path addCurveToPoint:CGPointMake(0.0f, size.height + shadowDepth)
            controlPoint1:CGPointMake(size.width - curlFactor, size.height + shadowDepth - curlFactor)
            controlPoint2:CGPointMake(curlFactor, size.height + shadowDepth - curlFactor)];
    
    imageView.layer.shadowPath = path.CGPath;
}

@end
