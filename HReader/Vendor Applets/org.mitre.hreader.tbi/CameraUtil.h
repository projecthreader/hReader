//
//  CameraUtil.h
//  HReader
//
//  Created by Kaye, Lindsay M on 9/24/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CameraUtil : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

-(IBAction)useCamera: (id) sender;
-(IBAction)useCamerRoll:(id)sender;
+(void)saveImage:(UIImage*)image;
+(NSArray*)getAllImages;

@end
