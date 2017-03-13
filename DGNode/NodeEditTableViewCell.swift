//
//  NodeEditTableViewCell.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/13.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit

class NodeEditTableViewCell: UITableViewCell, ReuseableCell {

    let textView = NodeTextView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(textView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
