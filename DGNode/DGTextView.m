//
//  DGTextView.m
//  DGNode
//
//  Created by DSKcpp on 2017/3/14.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

#import "DGTextView.h"

@interface YYTextView (DG)
@property (nonatomic, strong) YYTextRange *selectedTextRange;
- (void)_updateSelectionView;
@end

@implementation DGTextView

- (void)setSelectedTextRange:(YYTextRange *)selectedTextRange
{
    if (!_isHasHeadImage) {
        [super setSelectedTextRange:selectedTextRange];
    }
}

- (void)_updateSelectionView
{
    if (!_isHasHeadImage) {
        [super _updateSelectionView];
        return;
    }
    
    YYTextRange *range = self.selectedTextRange;
    NSLog(@"%@", range);
    if (range.start.offset == 0 || range.start.offset == 1) {
        [super _updateSelectionView];
    } else {
        [super _updateSelectionView];
    }
    
}

@end
