//
//  UIBarButtonItem+Reactive.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/11.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import Foundation
import ReactiveCocoa

extension UIBarButtonItem {
    
    convenience init(title: String?, style: UIBarButtonItemStyle, pressed: CocoaAction<UIBarButtonItem>) {
        self.init(title: title, style: style, target: nil, action: nil)
        reactive.pressed = pressed
    }
    
    convenience init(image: UIImage?, style: UIBarButtonItemStyle, pressed: CocoaAction<UIBarButtonItem>) {
        self.init(image: image, style: style, target: nil, action: nil)
        reactive.pressed = pressed
    }
    
    convenience init(barButtonSystemItem systemItem: UIBarButtonSystemItem, pressed: CocoaAction<UIBarButtonItem>) {
        self.init(barButtonSystemItem: systemItem, target: nil, action: nil)
        reactive.pressed = pressed
    }
}
