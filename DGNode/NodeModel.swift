//
//  NodeModel.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import YYText

class NodeModel: DGDataModel {
    
    var nodeID: Int = 0
    var content: String = ""
    var headImage: UIImage?
    var headImageScrollRect: CGRect = .zero
    var zoomScale: CGFloat = 1
    
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
}
