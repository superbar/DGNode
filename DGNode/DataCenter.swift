//
//  DataCenter.swift
//  DGNode
//
//  Created by DSKcpp on 2017/3/15.
//  Copyright © 2017年 DSKcpp. All rights reserved.
//

import UIKit
import CoreData

class DataCenter {

    static let shared = DataCenter()
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "DataCenter", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("DataCenter.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
            ]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            print("Failed to initialize the application's saved data")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func searchEntities(description: NSEntityDescription, predicate: NSPredicate?, sort: [NSSortDescriptor]?) throws -> [NSManagedObject]? {
        let name = description.name
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name!);
        fetchRequest.entity = description
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sort
        do {
            let result = try self.managedObjectContext.fetch(fetchRequest) as? [NSManagedObject]
            return result
        } catch {
            print(error)
            return nil
        }
    }
    
    func deleteEntity(description:NSEntityDescription,predicate:NSPredicate?,sort:[NSSortDescriptor]?) {
        let entities:[NSManagedObject]?
        do {
            entities = try searchEntities(description: description, predicate: predicate, sort: sort)
        } catch {
            entities = []
        }
        self.managedObjectContext.performAndWait { () -> Void in
            entities!.forEach({DataCenter.shared.managedObjectContext.delete($0)})
        }
        
    }
    
    func deleteEntities() {
        let Classes = [Node.entityDescription()]
        Classes.forEach { desc in
            self.deleteEntity(description: desc, predicate: nil, sort: nil)
        }
    }
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
