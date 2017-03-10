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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setNode(_ node: NodeModel) {
        guard let textLayout = node.textLayout else { return }
        nodeTextView.textLayout = textLayout
        let height = textLayout.textBoundingSize.height
        nodeTextView.frame = CGRect(x: 12, y: 0, width: UIScreen.main.bounds.width - 24, height: height)
        nodeTextView.center.y = contentView.center.y
    }
}
