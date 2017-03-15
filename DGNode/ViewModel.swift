//
//  ViewModel.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/15.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

class ViewModel {

    let disposables = CompositeDisposable()
    
    deinit {
        disposables.dispose()
    }
}
