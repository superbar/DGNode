//
//  Node+CoreDataProperties.swift
//  
//
//  Created by DSKcpp on 2017/3/15.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Node {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Node> {
        return NSFetchRequest<Node>(entityName: "Node");
    }

    @NSManaged public var content: String?
    @NSManaged public var headImage: Data?
    @NSManaged public var headImageOffsetX: Float
    @NSManaged public var headImageOffsetY: Float
    @NSManaged public var zoomScale: Float

}
