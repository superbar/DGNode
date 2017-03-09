//
//  NodeToolBarView.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/10.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit

class NodeToolBarView: UIView {

    let textAligmentButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textAligmentButton.setTitle("对齐", for: .normal)
        textAligmentButton.setTitleColor(.black, for: .normal)
        textAligmentButton.layer.borderColor = UIColor.black.cgColor
        textAligmentButton.layer.borderWidth = 1.0
        self.addSubview(textAligmentButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
