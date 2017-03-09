//
//  ShareBoardItem.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/9.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit

enum SharePlaform: Int {
    case sina               = 0
    case wechatSession      = 1
    case wechatTimeLine     = 2
    case QQ                 = 4
}

enum ShareBoardOtherAction: Int {
    case saveToPhotoLibrary
}

class ShareBoardItem {
    
    var title: String = ""
    var image: UIImage?
    var plaform: SharePlaform = .sina
    var otherAction: ShareBoardOtherAction = .saveToPhotoLibrary
    
    init(title: String, image: UIImage?, plaform: SharePlaform = .sina, otherAction: ShareBoardOtherAction = .saveToPhotoLibrary) {
        self.title = title
        self.image = image
        self.plaform = plaform
        self.otherAction = otherAction
    }
}
