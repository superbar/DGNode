//
//  ViewModelService.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit

protocol ViewModelService {
    
    func pushViewModel<T: ViewModelProtocol>(_ viewModel: T,animated: Bool)
    func pushViewModel<T: ViewModelProtocol>(_ viewModel: T,mayExists: Bool)
    
    func popToRootViewModel(animated: Bool)
    func popViewModelAnimated(animated: Bool)
    
    func presentViewModel<T: ViewModelProtocol>(_ viewModel: T,animated: Bool, completion:(() -> Void)?)
    func dismissViewModelAnimated(animated: Bool, completion: (() -> Void)?)
    
    func resetRootViewModel<T: ViewModelProtocol>(_ viewModel: T)
    
    func pushStack(navigationController: UINavigationController)
    func popStack() -> UINavigationController?
}
