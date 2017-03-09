//
//  ImagePickerViewModel.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit

class ImagePickerViewModel {
    
    let exec:((UIImage?, NSURL?) -> ())
    
    let source: UIImagePickerControllerSourceType
    let mediaTypes: [String]?
    
    init(source: UIImagePickerControllerSourceType, mediaTypes: [String]? = nil, exec: @escaping (UIImage?, NSURL?) -> ()) {
        self.source = source
        self.mediaTypes = mediaTypes
        self.exec = exec
    }
}
