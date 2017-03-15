//
//  UITableView+Extension.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import Foundation

protocol ReuseableCell { }

extension ReuseableCell where Self: UIView {
    static var reuseIdentifier: String { return String(describing: self) }
}

extension UITableView {
    
    func register<T: UITableViewCell>(_: T.Type) where T: ReuseableCell {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T where T: ReuseableCell {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell;
    }
}
