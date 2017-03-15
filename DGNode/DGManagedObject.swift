//
//  DGManagedObject.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/15.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import CoreData

extension NSManagedObject {
    
    class func entityName() -> String {
        fatalError("should overrid")
    }
    
    class func newEntity() -> NSManagedObject {
        let context = DataCenter.shared.managedObjectContext
        let entity = NSEntityDescription.insertNewObject(forEntityName: self.entityName(), into: context)
        return entity
    }
    
    class func entityDescription() -> NSEntityDescription {
        let context = DataCenter.shared.managedObjectContext
        return NSEntityDescription.entity(forEntityName: entityName(), in: context)!
    }
}
