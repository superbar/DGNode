//
//  DGAlertController.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit

class DGAlertController: UIAlertController {

}

extension DGAlertViewModel: ViewModelProtocol {
    
    func getViewController() -> UIViewController {
        let alert = UIAlertController(title: title.value, message: message.value, preferredStyle: preferredStyle.value)
        actions.value.forEach { action in
            alert.addAction(action)
        }
        return alert
    }
}
