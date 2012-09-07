//
//  tbiTestMemoryViewController.h
//  HReader
//
//  Created by Saltzman, Shep on 8/16/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestViewController.h"
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface tbiTestMemoryViewController : TestViewController 

- (IBAction) playSound: (id)sender;

@property (retain, nonatomic) IBOutlet UITextField *memory_word_recall_field1;
@property (retain, nonatomic) IBOutlet UITextField *memory_word_recall_field2;
@property (retain, nonatomic) IBOutlet UITextField *memory_word_recall_field3;
@property (retain, nonatomic) IBOutlet UITextField *memory_word_recall_field4;
@property (retain, nonatomic) IBOutlet UITextField *memory_word_recall_field5;

@property (retain, nonatomic) IBOutlet UIButton *playButton;

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

@end
