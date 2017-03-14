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
    
//    SwizzleMethod(YYTextView, @selector(_getAutoscrollOffset), @selector(dg_getAutoscrollOffset), NO)
//    SwizzleMethod(YYTextView, @selector(_scrollRangeToVisible:), @selector(dg_scrollRangeToVisible:), NO)
    
#pragma clang diagnostic pop
}

- (CGFloat)dg_getAutoscrollOffset
{
    return 0.0f;
}

- (void)dg_scrollRangeToVisible:(YYTextRange *)range
{
    
}

@end
