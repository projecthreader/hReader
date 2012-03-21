//
//  PINCodeSecurityQuestionsViewController.m
//  HReader
//
//  Created by Marshall Huss on 3/7/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "PINCodeSecurityQuestionsViewController.h"
#import "PINCodeTextField.h"
#import "PINCodeViewController.h"

static NSString * const PINCodeSecurityQuestionsKey = @"PINCodeSecurityQuestions";

@interface PINCodeSecurityQuestionsViewController () {
    NSMutableDictionary *data;
    PINSecurityQuestionMode __mode;
}

@end

@implementation PINCodeSecurityQuestionsViewController

@synthesize tableView = __tableView;

#pragma mark - object lifecycle

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        data = [[NSMutableDictionary alloc] init];
//        [[NSNotificationCenter defaultCenter]
//         addObserver:self
//         selector:@selector(keyboardWillShow:)
//         name:UIKeyboardWillShowNotification
//         object:nil];
//        [[NSNotificationCenter defaultCenter]
//         addObserver:self
//         selector:@selector(keyboardWillHide:)
//         name:UIKeyboardWillHideNotification
//         object:nil];
        __mode = 0;
    }
    return self;
}

- (void)dealloc {
    [data release];
    data = nil;
    [super dealloc];
}

#pragma mark - property overrides

- (void)setMode:(PINSecurityQuestionMode)mode {
    NSAssert((mode > 0 && mode < 4), @"You must provide a valid mode");
    if (__mode == 0) {
        __mode = mode;
    }
    NSAssert(__mode == mode, @"wat");
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSAssert(__mode > 0, @"The security mode % question mode must be set");
    UIImage *backgroundImage = [UIImage imageNamed:@"PINCodeBackground"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    self.tableView.backgroundView = nil;
    if (__mode != PINSecurityQuestionModeCreate) {
        NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:PINCodeSecurityQuestionsKey];
        [array enumerateObjectsUsingBlock:^(NSString *question, NSUInteger idx, BOOL *stop) {
            [data setObject:question forKey:[NSString stringWithFormat:@"Question%lx", (unsigned long)idx]];
        }];
    }
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
}

#pragma mark - button actions

- (IBAction)done {
    
    // get data
    NSArray *keys = [data allKeys];
    
    NSArray *questions = [[keys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF LIKE 'Question*'"]]
                          sortedArrayUsingSelector:@selector(compare:)];
    NSArray *answers = [[keys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF LIKE 'Answer*'"]]
                        sortedArrayUsingSelector:@selector(compare:)];
    
    // store questions in user defaults
    [[NSUserDefaults standardUserDefaults] setObject:questions forKey:PINCodeSecurityQuestionsKey];
    
    // store answers in keychain
    [PINCodeViewController setAnswersForSecurityQuestions:answers];
    
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
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
        field.enabled = (__mode != PINSecurityQuestionModeVerify);
        field.placeholder = @"Question";
        NSString *key = [NSString stringWithFormat:@"Question%ld", indexPath.section];
        field.key = key;
        field.text = [data objectForKey:key];
    }
    else if (indexPath.row == 1) {
        field.enabled = YES;
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
