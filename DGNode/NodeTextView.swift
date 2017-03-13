//
//  NodeTextView.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/12.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import YYText

class NodeTextView: YYTextView, YYTextKeyboardObserver {

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func keyboardChanged(with transition: YYTextKeyboardTransition) {
        
    }

}
