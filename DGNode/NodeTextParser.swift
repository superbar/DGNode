//
//  NodeTextParser.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/10.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import YYText

class NodeTextParser: NSObject, YYTextParser {

    func parseText(_ text: NSMutableAttributedString?, selectedRange: NSRangePointer?) -> Bool {
        guard let text = text else { return true }
        text.yy_setFont(UIFont.systemFont(ofSize: 14.0), range: text.yy_rangeOfAll())
        text.yy_setColor(UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0), range: text.yy_rangeOfAll())
        text.yy_setLineSpacing(8.0, range: text.yy_rangeOfAll())
        text.yy_setKern(1.0, range: text.yy_rangeOfAll())
        return true
    }
}
