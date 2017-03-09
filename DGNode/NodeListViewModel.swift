//
//  NodeListViewModel.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import ReactiveSwift

class NodeListViewModel {
    
    let nodes: MutableProperty<[NodeModel]> = MutableProperty([])
    
    init() {
        fetchNodes()
    }
    
    func fetchNodes() {

        guard let nodes: [NodeModel] = NodeModel.objectsWhere(nil, arguments: nil) as? [NodeModel] else { return }
        self.nodes.value = nodes
    }
}
