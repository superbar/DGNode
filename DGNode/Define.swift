//
//  Define.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/15.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import SwiftHEXColors

struct Configs {
    
    struct WeChat {
        static let appKey = "wxd6dc07784f2c6722"
        static let appSecret = "6a4daf701bfe0bc1f1209580c01a1945"
    }
    
    struct UMeng {
        static let appKey = "5861e5daf5ade41326001eab"
        static let redirectURL = "5861e5daf5ade41326001eab"
    }
}

extension UIColor {
    
    class var nodeColor: UIColor {
        return UIColor(hexString: "555555") ?? .black
    }
    
    class var nodeListColor: UIColor {
        return UIColor(hexString: "8F8F94") ?? .black
    }
}

extension UIFont {
    
    class var nodeFont: UIFont {
        return UIFont.systemFont(ofSize: 16.0)
    }
    
    class var nodeListFont: UIFont {
        return UIFont.systemFont(ofSize: 14.0)
    }
}
