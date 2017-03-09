//
//  UIView+Frame.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit

extension UIView {
    
    var left: CGFloat {
        get {
            return frame.minX
        } set {
            frame.origin.x = newValue
        }
    }
    
    var right: CGFloat {
        get {
            return frame.maxX
        } set {
            frame.origin.x = newValue - frame.width
        }
    }
    
    var top: CGFloat {
        get {
            return frame.minY
        } set {
            frame.origin.y = newValue
        }
    }
    
    var bottom: CGFloat {
        get {
            return frame.maxY
        } set {
            frame.origin.y = newValue - frame.height
        }
    }
    
    var width: CGFloat {
        get {
            return frame.width
        } set {
            frame.size.width = newValue;
        }
    }

    var height: CGFloat {
        get {
            return frame.height
        } set {
            frame.size.height = newValue
        }
    }
    
    
}

