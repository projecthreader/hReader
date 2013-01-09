//
//  HRMedicationsCollectionViewLayout.m
//  HReader
//
//  Created by DiCristofaro, Lauren M on 12/12/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import "HRMedicationsCollectionViewLayout.h"

@implementation HRMedicationsCollectionViewLayout
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *newAttributes = [NSMutableArray arrayWithCapacity:attributes.count];
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        if (attribute.frame.origin.x + attribute.frame.size.width <= self.collectionViewContentSize.width) {
            [newAttributes addObject:attribute];
        }
    }
    return newAttributes;
}
@end
