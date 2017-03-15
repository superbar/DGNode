//
//  Node+CoreDataClass.swift
//  
//
//  Created by DSKcpp on 2017/3/15.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

@objc(Node)
public class Node: NSManagedObject {
    
    override class func entityName() -> String {
        return "Node"
    }
    
    var text: String {
        get {
            return content ?? ""
        } set {
            content = newValue
        }
    }
    
    var image: UIImage? {
        get {
            guard let data = headImage else { return nil }
            return UIImage(data: data)
        } set {
            if let newValue = newValue {
                let start = CACurrentMediaTime()
                DispatchQueue.global().async {
                    let img = UIImagePNGRepresentation(newValue)
                    DispatchQueue.main.async {
                        self.headImage = img
                        print("\(CACurrentMediaTime() - start)")
                    }
                }
            } else {
                headImage = nil
            }
        }
    }
}
