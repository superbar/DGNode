//
//  DGTextView.m
//  DGNode
//
//  Created by DSKcpp on 2017/3/14.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

#import "DGTextView.h"
#import <objc/message.h>

@interface NSObject (DG)

@end

@implementation NSObject (DG)


@end


@interface YYTextView (DG)
@property (nonatomic, strong) YYTextRange *selectedTextRange;

- (void)_updateSelectionView;
- (void)selectAll:(id)sender;
- (void)_updateIfNeeded;
- (void)_updateOuterProperties;
- (void)_hideMenu;
- (void)_showMenu;
- (void)_endTouchTracking;
- (YYTextRange *)_getClosestTokenRangeAtPosition:(YYTextPosition *)position;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
@end

@implementation DGTextView

//- (void)setSelectedTextRange:(YYTextRange *)selectedTextRange
//{
////    if (!_isHasHeadImage) {
////        [super setSelectedTextRange:selectedTextRange];
////    }
//    [super setSelectedTextRange:selectedTextRange];
//}
//
//- (void)_updateSelectionView
//{
////    if (!_isHasHeadImage) {
////        [super _updateSelectionView];
////        return;
////    }
//    
//    [super _updateSelectionView];
//
//}
//
//- (void)select:(id)sender
//{
//    if (!_isHasHeadImage) {
//        [super select:sender];
//        return;
//    }
//    
//    [self _endTouchTracking];
//    
//    NSMutableAttributedString *innerText = [self valueForKey:@"innerText"];
//    
//    YYTextPosition *start = self.selectedTextRange.start;
//    if (start.offset == 0) {
//        start = [YYTextPosition positionWithOffset:1];
//    }
//    if (self.selectedTextRange.asRange.length > 0 || innerText.length == 0) return;
//    YYTextRange *newRange = [self _getClosestTokenRangeAtPosition:start];
//    if (newRange.asRange.length > 0) {
//        [self.inputDelegate selectionWillChange:self];
//        self.selectedTextRange = newRange;
//        [self.inputDelegate selectionDidChange:self];
//    }
//    
//    [self _updateIfNeeded];
//    [self _updateOuterProperties];
//    [self _updateSelectionView];
//    [self _hideMenu];
//    [self _showMenu];
//}
//
- (void)selectAll:(id)sender
{
    if (!_isHasHeadImage) {
        [super selectAll:sender];
        return;
    }
    
    YYTextRange *trackingRange = [self valueForKey:@"trackingRange"];
    trackingRange = nil;
    [self.inputDelegate selectionWillChange:self];
    NSMutableAttributedString *innerText = [self valueForKey:@"innerText"];
    self.selectedTextRange = [YYTextRange rangeWithRange:NSMakeRange(1, innerText.length)];
    [self.inputDelegate selectionDidChange:self];
    
    [self _updateIfNeeded];
    [self _updateOuterProperties];
    [self _updateSelectionView];
    [self _hideMenu];
    [self _showMenu];
}
//
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    if (!_isHasHeadImage) {
//        [super touchesBegan:touches withEvent:event];
//        return;
//    }
//    
//    [super touchesBegan:touches withEvent:event];
////    id selectionView = [self valueForKey:@"selectionView"];
////    Class cls = NSClassFromString(@"WBTextRenderer");
////    SEL sel = NSSelectorFromString(@"enableDebugMode");
////    objc_msgSend(cls, sel);
////    objc_msgSend(selectionView, @selector(setCaretVisible:), NO)
////    [selectionView performSelector:@selector(setCaretVisible:) withObject:NO];
//    return;
////    
////    YYTextPosition *start = self.selectedTextRange.start;
////    if (start.offset == 0) {
////        start = [YYTextPosition positionWithOffset:1];
////    }
////    YYTextRange *newRange = [self _getClosestTokenRangeAtPosition:start];
////    if (newRange.asRange.length > 0) {
////        self.selectedTextRange = newRange;
////    }
////    [super touchesBegan:touches withEvent:event];
//}

@end
