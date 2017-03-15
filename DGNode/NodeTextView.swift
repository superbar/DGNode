//
//  NodeTextView.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/12.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit

class NodeTextView: UITextView {
    
    let paese = NodeTextParser()
    
    private var _placeholderText = ""
    
    var placeholderText: String {
        get {
            return _placeholderText
        } set {
            _placeholderText = newValue
            self.setNeedsDisplay()
        }
    }
    
    private var _placeholderColor = UIColor.lightGray
    
    var placeholderColor: UIColor {
        get {
            return _placeholderColor
        } set {
            _placeholderColor = newValue
            self.setNeedsDisplay()
        }
    }
    
    private var _placeholderFont = UIFont.systemFont(ofSize: 14.0)
    var placeholderFont: UIFont {
        get {
            return _placeholderFont
        } set {
            _placeholderFont = newValue
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard !hasText else { return }
        
        let attr = [NSFontAttributeName : _placeholderFont, NSForegroundColorAttributeName : _placeholderColor] as [String : Any]
        let placeholder = NSAttributedString(string: _placeholderText, attributes: attr)
        let left = textContainerInset.left
        let top = textContainerInset.top
        placeholder.draw(in: rect.insetBy(dx: left + 5, dy: top))
    }
}
