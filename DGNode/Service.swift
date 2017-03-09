//
//  Service.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit

class Service {
    
    static let `default`: Service = {
        return Service();
    }()
    
    let viewModelService: ViewModelService = ViewModelServiceImpl()
}
