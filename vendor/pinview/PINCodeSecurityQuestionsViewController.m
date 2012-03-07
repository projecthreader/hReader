//
//  PINCodeSecurityQuestionsViewController.m
//  HReader
//
//  Created by Marshall Huss on 3/7/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "PINCodeSecurityQuestionsViewController.h"
#import "PINCodeTextField.h"

@interface PINCodeSecurityQuestionsViewController () {
    NSMutableDictionary *data;
}

@end

@implementation PINCodeSecurityQuestionsViewController

@synthesize tableView = __tableView;

#pragma mark - object lifecycle

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        data = [[NSMutableDictionary alloc] init];
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(keyboardWillShow:)
         name:UIKeyboardWillShowNotification
         object:nil];
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(keyboardWillHide:)
         name:UIKeyboardWillHideNotification
         object:nil];
    }
    return self;
}

- (void)dealloc {
    [data release];
    data = nil;
    [super dealloc];
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *backgroundImage = [UIImage imageNamed:@"PINCodeBackground"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    self.tableView.backgroundView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return YES;
}


#pragma mark - text fields

- (void)keyboardWillShow:(NSNotification *)notification {
//    [UIView
//     animateWithDuration:<#(NSTimeInterval)#>
//     delay:0.0
//     options:<#(UIViewAnimationOptions)#>
//     animations:<#^(void)animations#>
//     completion:<#^(BOOL finished)completion#>
}

- (BOOL)textFieldShouldReturn:(UITextField *)field {
    return YES;
}

- (void)textFieldTextDidChange:(NSNotification *)notification {
    
}

- (IBAction)valueChanged:(PINCodeTextField *)sender {
    [data setObject:sender.text forKey:sender.key];
    NSLog(@"%@", data);
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldCell"];
    NSArray *subviews = cell.contentView.subviews;
    NSAssert([subviews count] == 1, @"There should only be one view in the cell content view");
    PINCodeTextField *field = [subviews lastObject];
    if (indexPath.row == 0) {
        field.placeholder = @"Question";
        field.key = [NSString 
        field.key = [NSString stringWithFormat:@"Question%ld", indexPath.section];
    }
    else if (indexPath.row == 1) {
        field.placeholder = @"Answer";
        field.key = [NSString stringWithFormat:@"Answer%ld", indexPath.section];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Question %ld", (section + 1)];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat offset = 45.0;
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(offset, 0.0, tableView.frame.size.width - offset, 35.0)] autorelease];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont boldSystemFontOfSize:17.0];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    label.backgroundColor = [UIColor clearColor];
    label.opaque = YES;
    label.textColor = [UIColor whiteColor];
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, label.bounds.size.height)] autorelease];
    [view addSubview:label];
    return view;
}

@end
