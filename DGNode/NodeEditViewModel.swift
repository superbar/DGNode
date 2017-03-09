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
    
    let node: MutableProperty<NodeModel?> = MutableProperty(nil)
    
    let reloadNodeListSignal: Signal<Void, NoError>
    let reloadNodeListObserver: Observer<Void, NoError>
    
    init() {
        (reloadNodeListSignal, reloadNodeListObserver) = Signal<Void, NoError>.pipe()
    }
}
