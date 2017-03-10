//
//  DGAlertViewModel.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import ReactiveSwift

class DGAlertViewModel {

    let title = MutableProperty<String?>(nil)
    let message = MutableProperty<String?>(nil)
    let preferredStyle = MutableProperty<UIAlertControllerStyle>(.actionSheet)
    let actions = MutableProperty<[UIAlertAction]>([])
    
    init(title: String?, message: String?, preferredStyle: UIAlertControllerStyle) {
        self.title.value = title
        self.message.value = message
        self.preferredStyle.value = preferredStyle
    }
}
