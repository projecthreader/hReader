//
//  HRConfig.h
//  HReader
//
//  Created by Marshall Huss on 11/15/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@implementation HRConfig

+ (UIColor *)textureColor {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"handmadepaper"]];
}

+ (UIColor *)redColor {
    return [UIColor colorWithRed:148/255.0 green:17/255.0 blue:0/255.0 alpha:1.0];
}

+ (UIColor *)greenColor {
    return [UIColor colorWithRed:79/255.0 green:142/255.0 blue:0/255.0 alpha:1.0];
}

+ (UIColor *)lightRedColor {
    return [UIColor colorWithRed:216/255.0 green:83/255.0 blue:111/255.0 alpha:1.0];
}


+ (UIColor *)redGradientTopColor {
    return [UIColor colorWithRed:230/255.0 green:107/255.0 blue:124/255.0 alpha:1.0];
}

+ (UIColor *)redGradientBottomColor {
    return [UIColor colorWithRed:221/255.0 green:59/255.0 blue:81/255.0 alpha:1.0];
}

+ (void)setShadowForView:(UIView *)shadowView borderForView:(UIView *)borderView {
    CALayer *borderLayer = borderView.layer;
    CALayer *shadowLayer = shadowView.layer;
    
    // Rounded corners
    borderLayer.masksToBounds = YES;
    borderLayer.cornerRadius = 5.0f;
    
    // Shadow
    shadowView.backgroundColor = [UIColor clearColor];
    shadowLayer.shadowColor = [[UIColor blackColor] CGColor];
    shadowLayer.shadowOpacity = 0.5f;
    shadowLayer.shadowOffset = CGSizeMake(3.0f, 1.0f);
    shadowLayer.shadowRadius = 5.0f;
    
    // Border
    borderLayer.borderColor = [[UIColor blackColor] CGColor];
    borderLayer.borderWidth = 2.0f;
    
    
    
    // Page Curl
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