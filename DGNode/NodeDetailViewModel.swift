//
//  NodeDetailViewModel.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

class NodeDetailViewModel {

    let node: MutableProperty<NodeModel> = MutableProperty(NodeModel())
    
    let reloadNodeListSignal: Signal<Void, NoError>
    let reloadNodeListObserver: Observer<Void, NoError>
    
    init() {
        (reloadNodeListSignal, reloadNodeListObserver) = Signal<Void, NoError>.pipe()
    }
}
