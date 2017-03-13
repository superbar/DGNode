//
//  NodeDetailView.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import PureLayout
import YYText
import ReactiveSwift

class NodeDetailView: UIView {

    let headImageView = NodeHeadImageView()
    let nodeTextView = YYLabel()
    let totalHeight: MutableProperty<CGFloat> = MutableProperty(0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(headImageView)
        
//        headImageView.isScrollEnabled = false
        headImageView.deleteHeadImageButton.isHidden = true
        headImageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        headImageView.autoSetDimension(.height, toSize: 200)
        
        nodeTextView.ignoreCommonProperties = true
        addSubview(nodeTextView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setNode(_ node: NodeModel) {
        
        var totalHeight: CGFloat = 0.0
        if let headImage = node.headImage {
            headImageView.setImage(headImage)
            headImageView.isHidden = false
//            headImageView.scrollView.setContentOffset(node.headImageScrollRect.origin, animated: false)
            totalHeight += 200.0
        } else {
            headImageView.isHidden = true
        }
        
        if node.content.characters.count > 0 {
            let maxWidth = width - 70.0
            let text = NSMutableAttributedString(string: node.content)
            text.yy_setFont(UIFont.systemFont(ofSize: 14.0), range: text.yy_rangeOfAll())
            text.yy_setColor(UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0), range: text.yy_rangeOfAll())
            text.yy_setLineSpacing(8.0, range: text.yy_rangeOfAll())
            
            let textLayout = YYTextLayout(containerSize: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), text: text)
            nodeTextView.textLayout = textLayout
            nodeTextView.isHidden = false
            if !headImageView.isHidden {
                nodeTextView.top = headImageView.bottom + 30
            } else {
                nodeTextView.top = 30
            }
            nodeTextView.left = 35.0
            if let textLayout = textLayout {
                nodeTextView.width = maxWidth
                nodeTextView.height = textLayout.textBoundingSize.height
                totalHeight += textLayout.textBoundingSize.height + 60.0
            }
        } else {
            nodeTextView.isHidden = true
        }
        
        self.totalHeight.value = totalHeight
    }

}
