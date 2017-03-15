//
//  NodeListViewModel.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

class NodeListViewModel: ViewModel {
    
    let nodes: MutableProperty<[NodeModel]> = MutableProperty([])
    
    let createNewNodeCocoaAction: CocoaAction<UIBarButtonItem>
    let createNewNodeAction = Action(NodeListViewModel.createNewNodeSignalProducer)
    let editNodeAction = Action(NodeListViewModel.editNodeSignalProducer)
    
    override init() {
        createNewNodeCocoaAction = CocoaAction(createNewNodeAction)
        super.init()
        
        fetchNodes()
        
        createNewNodeAction.values.observeValues { [weak self] _ in
            guard let `self` = self else { return }
            self.fetchNodes()
        }
        
        editNodeAction.values.observeValues { [weak self] _ in
            guard let `self` = self else { return }
            print(Date())
            self.fetchNodes()
        }
    }
    
    func fetchNodes() {
        DispatchQueue.global().async {
//            let start = CACurrentMediaTime()
            let nodes: [NodeModel] = NodeModel.objectsWhere("ORDER BY nodeID DESC", arguments: nil) as! [NodeModel]
//            print(CACurrentMediaTime() - start)
            self.nodes.value = nodes
        }
    }
}

fileprivate extension NodeListViewModel {
    
    class func createNewNodeSignalProducer() -> SignalProducer<Void, NoError> {
        return SignalProducer { observer, disposable in
            let viewModel = NodeEditViewModel()
            viewModel.reloadNodeListSignal.observeValues { isChange in
                if isChange {
                    observer.send(value: ())
                }
            }
            viewModel.reloadNodeListSignal.observeCompleted {
                observer.sendCompleted()
            }
            Service.default.viewModelService.pushViewModel(viewModel, animated: true)
        }
    }
    
    class func editNodeSignalProducer(node: NodeModel) -> SignalProducer<Void, NoError> {
        return SignalProducer { observer, disposable in
            let viewModel = NodeEditViewModel()
            viewModel.node.value = node
            viewModel.reloadNodeListSignal.observeValues { isChange in
                if isChange {
                    observer.send(value: ())
                }
            }
            viewModel.reloadNodeListSignal.observeCompleted {
                observer.sendCompleted()
            }
            Service.default.viewModelService.pushViewModel(viewModel, animated: true)
        }
    }
}
