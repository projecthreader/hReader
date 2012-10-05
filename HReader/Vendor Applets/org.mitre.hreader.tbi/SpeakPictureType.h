//
//  SpeakPictureType.h
//  HReader
//
//  Created by Kaye, Lindsay M on 9/24/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpeakPictureType : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate> {
    UIImageView * imageView;
}
@property (nonatomic, retain) IBOutlet UIButton *cameraButton;
@property (nonatomic, retain) IBOutlet UIButton * speakButton;
@property (nonatomic, retain) IBOutlet UIButton * textButton;

@property (nonatomic, retain) IBOutlet UIScrollView * scrollView;


- (IBAction) launchOpenEars:(id)sender;
- (IBAction) presentTextBox:(id)sender;
- (IBAction) presentCamera:(id)sender;

- (void)setupverticalScrollView;

- (BOOL) startCameraControllerFromViewController:(UIViewController*)controller usingDelegate: (id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate;
@end