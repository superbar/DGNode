//
//  YYTextView+Load.m
//  DGNode
//
//  Created by DSKcpp on 2017/3/14.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

#import "YYTextView+Load.h"
#import <objc/runtime.h>

# define SwizzleMethod(className, originalSelector, swizzledSelector, isClassMethod) \
{ \
Class cls = objc_getClass(#className); \
Method originalMethod = isClassMethod ? class_getClassMethod(cls, originalSelector) : class_getInstanceMethod(cls, originalSelector); \
Method swizzledMethod = isClassMethod ? class_getClassMethod(cls, swizzledSelector) : class_getInstanceMethod(cls, swizzledSelector); \
\
Class _cls = isClassMethod ? object_getClass(cls) : cls; \
BOOL isAddMethod = class_addMethod(_cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod)); \
\
if (isAddMethod) { \
class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod)); \
} else { \
method_exchangeImplementations(originalMethod, swizzledMethod); \
} \
} \

@implementation YYTextView (Load)
+ (void)load
{
#pragma("clang diagnostic push")
#pragma clang diagnostic ignored "-Wundeclared-selector"
    
    SwizzleMethod(YYTextView, @selector(setSelectedTextRange:), @selector(dg_setSelectedTextRange:), NO)
    
#pragma clang diagnostic pop
}

- (void)dg_setSelectedTextRange:(YYTextRange *)selectedTextRange
{
    NSLog(@"dg_setSelectedTextRange");
}

@end

@interface YYTextLayout (Load)

@end

@implementation YYTextLayout (Load)
+ (void)load
{
#pragma("clang diagnostic push")
#pragma clang diagnostic ignored "-Wundeclared-selector"
    
    SwizzleMethod(YYTextLayout, @selector(selectionRectsForRange:), @selector(dg_selectionRectsForRange:), NO)
    
#pragma clang diagnostic pop
}

- (NSArray *)dg_selectionRectsForRange:(YYTextRange *)range
{
    if (range.start.offset == 1 && range.end.offset == 1) {
        return @[];
    } else {
        return [self dg_selectionRectsForRange:range];
    }
}

@end
