//
//  Subject.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/26/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import Foundation
import CoreData


class Subject: NSManagedObject {
    
    static let managedContext :NSManagedObjectContext = CoreDataStackManager.sharedManager.managedObjectContext
    
    static func createSubject(name: String, managedObjectContext : NSManagedObjectContext, temporary: Bool)->Subject? {
        let predicate = NSPredicate(format: "name like %@", "\(name)")
        
        let fetchItemWithSameId = NSFetchRequest(entityName: "Subject")
        
        fetchItemWithSameId.predicate = predicate
        let fetchedItems : NSArray?
        do {
            fetchedItems = try self.managedContext.executeFetchRequest(fetchItemWithSameId)
            var subject: Subject?
            if (fetchedItems!.count == 0) {
                let entity = NSEntityDescription.entityForName("Subject", inManagedObjectContext: managedObjectContext)!
                subject = NSManagedObject(entity: entity, insertIntoManagedObjectContext: temporary ? nil : managedObjectContext) as? Subject
            }else {
                subject = fetchedItems?.firstObject as? Subject
            }
            subject?.name = name
            do{
                if !temporary {
                    try managedObjectContext.save()
                }
            }catch let error as NSError {
                print("Save managedObjectContext failed: \(error.localizedDescription)")
            }
            return subject
        }catch let error as NSError{
            print("Fetch failed: \(error.localizedDescription)")
        }
        return nil
    }
}