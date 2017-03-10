//
//  NodeEditViewModel.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result


class NodeEditViewModel {
    
    let node: MutableProperty<NodeModel> = MutableProperty(NodeModel())
    let hasHeadImage = MutableProperty(false)
    
    let reloadNodeListSignal: Signal<Bool, NoError>
    let reloadNodeListObserver: Observer<Bool, NoError>
    
    let addHeadImageCocoaAction: CocoaAction<UIBarButtonItem>
    let addHeadImageAction = Action(NodeEditViewModel.addHeadImageSignalProducer)
    
    init() {
        (reloadNodeListSignal, reloadNodeListObserver) = Signal<Bool, NoError>.pipe()
        addHeadImageCocoaAction = CocoaAction(addHeadImageAction)
    }
    
    deinit {
        reloadNodeListObserver.sendCompleted()
    }
}

fileprivate extension NodeEditViewModel {
    
    class func addHeadImageSignalProducer() -> SignalProducer<UIImage?, NoError> {
        return SignalProducer { observer, disposable in
            let viewModel = DGAlertViewModel(title: "添加题图", message: nil, preferredStyle: .actionSheet)
            let crameAction = UIAlertAction(title: "拍照", style: .default, handler: { action in
                pickerImage(observer: observer, source: .camera)
            })
            let photoLibraryAction = UIAlertAction(title: "从相册选取", style: .default, handler: { action in
                pickerImage(observer: observer, source: .photoLibrary)
            })
            let cancelAciton = UIAlertAction(title: "取消", style: .cancel, handler: { action in
                observer.sendCompleted()
            })
            viewModel.actions.value = [crameAction, photoLibraryAction, cancelAciton]
            Service.default.viewModelService.presentViewModel(viewModel, animated: true, completion: nil)
        }
    }
    
    class func pickerImage(observer: Observer<UIImage?, NoError>, source: UIImagePickerControllerSourceType) {
        if DGImagePickerController.available(source: source) {
            let viewModel = DGImagePickerViewModel(source: source, exec: { image, url in
                observer.send(value: image)
                observer.sendCompleted()
            })
            Service.default.viewModelService.presentViewModel(viewModel, animated: true, completion: nil)
        } else {
            observer.send(value: nil)
            observer.sendCompleted()
        }
    }
}
