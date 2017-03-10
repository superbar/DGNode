//
//  NodeEditViewModel.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result


class NodeEditViewModel {
    
    let node: MutableProperty<NodeModel> = MutableProperty(NodeModel())
    let hasHeadImage = MutableProperty(false)
    
    let reloadNodeListSignal: Signal<NodeModel, NoError>
    let reloadNodeListObserver: Observer<NodeModel, NoError>
    
    init() {
        (reloadNodeListSignal, reloadNodeListObserver) = Signal<NodeModel, NoError>.pipe()
    }
    
    deinit {
        reloadNodeListObserver.sendCompleted()
    }
}
