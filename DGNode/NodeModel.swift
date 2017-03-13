//
//  NodeModel.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import YYText
import SwiftHEXColors

class NodeModel: DGDataModel {
    
    var nodeID: Int = 0
    var content: String = ""
    var headImage: UIImage?
    var headImageScrollRect: CGRect = .zero
    var zoomScale: CGFloat = 1
    var textLayout: YYTextLayout?
    
    var height: CGFloat = 0
    
    override class func tableName() -> String {
        return "Node"
    }
    
    override class func primaryKey() -> String {
        return "nodeID"
    }
    
    static let properties: [String] = {
        return ["nodeID", "content", "headImage", "headImageScrollRect", "zoomScale"]
    }()
    
    override class func persistentProperties() -> [Any] {
        return properties
    }
    
    func newTextLayout() {
        let width = UIScreen.main.bounds.width - 24.0
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let text: NSMutableAttributedString = NSMutableAttributedString(string: self.content)
        text.yy_setFont(UIFont.systemFont(ofSize: 14.0), range: text.yy_rangeOfAll())
        text.yy_setColor(UIColor(red: 143/255, green: 143/255, blue: 148/255, alpha: 1.0), range: text.yy_rangeOfAll())
        let textContainer = YYTextContainer(size: size)
        textContainer.maximumNumberOfRows = 4
        textContainer.truncationType = .end
        guard let textLayout = YYTextLayout(container: textContainer, text: text) else { return }
        let height = max(textLayout.textBoundingSize.height + 24, 44.0)
        self.height = height
        self.textLayout = textLayout
    }
}
