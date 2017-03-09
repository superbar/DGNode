//
//  NodeListTableViewCell.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import YYText
import PureLayout

class NodeListTableViewCell: UITableViewCell, ReuseableCell {
    
    var nodeTextView = YYLabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nodeTextView.ignoreCommonProperties = true
        contentView.addSubview(nodeTextView)
        
        nodeTextView.autoPinEdge(toSuperviewEdge: .left, withInset: 12.0)
        nodeTextView.autoPinEdge(toSuperviewEdge: .right, withInset: 12.0)
        nodeTextView.autoAlignAxis(toSuperviewAxis: .horizontal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func setNode(_ node: NodeModel) {
        nodeTextView.textLayout = node.textLayout
        nodeTextView.frame.size = node.textLayout.textBoundingSize
    }
}
