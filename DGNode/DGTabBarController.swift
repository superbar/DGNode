//
//  DGTabBarController.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit

class DGTabBarController: UITabBarController {

    let viewModel: DGTabBarViewModel
    init(viewModel: DGTabBarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nodeListVC = NodeListViewController(viewModel: NodeListViewModel())
        let nodeListNavController = UINavigationController(rootViewController: nodeListVC)
        
        setViewControllers([nodeListNavController], animated: false)
        
        Service.default.viewModelService.pushStack(navigationController: nodeListNavController)
    }
}


extension DGTabBarViewModel: ViewModelProtocol {
    
    func getViewController() -> UIViewController {
        return DGTabBarController(viewModel: self)
    }
}
