//
//  NodeModel.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import GYDataCenter
import YYText

class NodeModel: GYModelObject {
    
    var nodeID: Int = 0
    var content: String = ""
    var headImage: UIImage?
    var headImageScrollRect: CGRect?
    lazy var textLayout: YYTextLayout = {
        let width = UIScreen.main.bounds.width - 24.0
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        var text: NSMutableAttributedString = NSMutableAttributedString(string: self.content)
        text.yy_setFont(UIFont.systemFont(ofSize: 18.0), range: text.yy_rangeOfAll())
        text.yy_setColor(.black, range: text.yy_rangeOfAll())
        let textContainer = YYTextContainer(size: size)
        textContainer.maximumNumberOfRows = 3
        let textLayout = YYTextLayout(container: textContainer, text: text)
        let height = max(textLayout?.textBoundingSize.height ?? 0 + 24.0, 44.0)
        self.height = height
        return textLayout!
    }()
    
    var height: CGFloat = 0
    
    override class func dbName() -> String {
        return "DGNode_DB"
    }
    
    override class func tableName() -> String {
        return "Node"
    }
    
    override class func primaryKey() -> String {
        return "nodeID"
    }
    
    static let properties: [String] = {
        return ["nodeID", "content"]
    }()
    
    override class func persistentProperties() -> [Any] {
        return properties
    }
}
