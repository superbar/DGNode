//
//  NodeListHeaderView.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import PureLayout

class NodeListHeaderView: UIView {

    let createNewNodeButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createNewNodeButton.setTitle("创建", for: .normal)
        createNewNodeButton.setTitleColor(.white, for: .normal)
        createNewNodeButton.setBackgroundImage(UIImage.image(.green), for: .normal)
        createNewNodeButton.layer.masksToBounds = true
        createNewNodeButton.layer.cornerRadius = 5.0
        addSubview(createNewNodeButton)
        
        createNewNodeButton.autoPinEdge(toSuperviewEdge: .left, withInset: 24.0)
        createNewNodeButton.autoPinEdge(toSuperviewEdge: .right, withInset: 24.0)
        createNewNodeButton.autoSetDimension(.height, toSize: 44)
        createNewNodeButton.autoAlignAxis(toSuperviewAxis: .horizontal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
