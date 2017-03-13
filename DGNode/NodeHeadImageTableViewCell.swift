//
//  NodeHeadImageTableViewCell.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/13.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit

class NodeHeadImageTableViewCell: UITableViewCell, ReuseableCell {

    let headImage = NodeHeadImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(headImage)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        headImage.frame = bounds
    }
}
