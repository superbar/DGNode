//
//  DGTextView.m
//  DGNode
//
//  Created by DSKcpp on 2017/3/14.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

#import "DGTextView.h"

@implementation DGTextView

- (void)setSelectedTextRange:(YYTextRange *)selectedTextRange
{
    if (!_isHasHeadImage) {
        [super setSelectedTextRange:selectedTextRange];
    }
}

@end
