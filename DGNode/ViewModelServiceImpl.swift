//
//  ViewModelServiceImpl.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit

class ViewModelServiceImpl: ViewModelService {
    
    private var navigationControllerStack: [UINavigationController] = []
    
    func pushStack(navigationController: UINavigationController) {
        guard !navigationControllerStack.contains(navigationController) else { return }
        navigationControllerStack.append(navigationController)
    }
    
    func popStack() -> UINavigationController? {
        guard let navigationController = navigationControllerStack.last else { return nil }
        navigationControllerStack.removeLast()
        return navigationController
    }
    
    func pushViewModel<T: ViewModelProtocol>(_ viewModel: T, animated: Bool) {
        let viewController = viewModel.getViewController()
        viewController.hidesBottomBarWhenPushed = true
        navigationControllerStack.last?.pushViewController(viewController, animated: animated)
    }
    
    func pushViewModel<T: ViewModelProtocol>(_ viewModel: T, mayExists: Bool) {
        let pushViewController = viewModel.getViewController()
        guard let navigationController = navigationControllerStack.last else { return }
        for i in 0..<navigationController.viewControllers.count {
            let viewController = navigationController.viewControllers[i]
            if object_getClassName(viewController) == object_getClassName(pushViewController) {
                navigationController.popToViewController(viewController, animated: true)
                return
            }
        }
        navigationController.pushViewController(pushViewController, animated: true)
    }
    
    func presentViewModel<T: ViewModelProtocol>(_ viewModel: T, animated: Bool, completion: (() -> Void)?) {
        var viewController = viewModel.getViewController()
        if viewController.isKind(of: UIAlertController.self) {
            navigationControllerStack.last?.present(viewController, animated: animated, completion: completion)
            return
        }
        if !viewController.isKind(of: UINavigationController.self) {
            viewController = UINavigationController(rootViewController: viewController)
        }
        let navigationController = navigationControllerStack.last
        pushStack(navigationController: viewController as! UINavigationController)
        navigationController?.present(viewController, animated: animated, completion: completion)
    }
    
    func dismissViewModelAnimated(animated: Bool, completion: (() -> Void)?) {
        _ = popStack()
        navigationControllerStack.last?.dismiss(animated: animated, completion: completion)
    }
    
    func popToRootViewModel(animated: Bool) {
        _ = navigationControllerStack.last?.popToRootViewController(animated: animated)
    }
    
    func popViewModelAnimated(animated: Bool) {
        _ = navigationControllerStack.last?.popViewController(animated: animated)
    }
    
    func resetRootViewModel<T: ViewModelProtocol>(_ viewModel: T) {
        navigationControllerStack.removeAll()
        var viewController = viewModel.getViewController()
        if !viewController.isKind(of: UINavigationController.self) && !viewController.isKind(of: UITabBarController.self) {
            viewController = UINavigationController(rootViewController: viewController)
            pushStack(navigationController: viewController as! UINavigationController)
        }
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = viewController
    }
}
