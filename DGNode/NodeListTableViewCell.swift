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
    
    var nodeTextView = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nodeTextView.numberOfLines = 4
        contentView.addSubview(nodeTextView)
        nodeTextView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setNode(_ node: NodeModel) {
        let content = node.content.replacingOccurrences(of: "\n", with: "")
        let text: NSMutableAttributedString = NSMutableAttributedString(string: content)
        text.yy_setFont(.nodeListFont, range: text.yy_rangeOfAll())
        text.yy_setColor(.nodeListColor, range: text.yy_rangeOfAll())
        text.yy_setLineSpacing(2.0, range: text.yy_rangeOfAll())
        text.yy_setLineBreakMode(.byTruncatingTail, range: text.yy_rangeOfAll())
        nodeTextView.attributedText = text
    }
}
