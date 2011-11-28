//
//  UIColor.m
//  HReader
//
//  Created by Marshall Huss on 11/21/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import "UIColor+hReader.h"

@implementation UIColor (hreader)

+ (UIColor *)hReaderTexture {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"handmadepaper"]];
}

+ (UIColor *)hReaderRed {
    return [UIColor colorWithRed:148/255.0 green:17/255.0 blue:0/255.0 alpha:1.0];
}

+ (UIColor *)hReaderGreen {
    return [UIColor colorWithRed:79/255.0 green:142/255.0 blue:0/255.0 alpha:1.0];
}

+ (UIColor *)hReaderLightRed {
    return [UIColor colorWithRed:216/255.0 green:83/255.0 blue:111/255.0 alpha:1.0];
}


+ (UIColor *)hReaderRedGradientTop {
    return [UIColor colorWithRed:230/255.0 green:107/255.0 blue:124/255.0 alpha:1.0];
}

+ (UIColor *)hReaderRedGradientBottom {
    return [UIColor colorWithRed:221/255.0 green:59/255.0 blue:81/255.0 alpha:1.0];
}

@end
