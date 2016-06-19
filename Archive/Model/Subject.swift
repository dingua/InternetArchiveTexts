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
    
    static let managedObjectContext :NSManagedObjectContext = CoreDataStackManager.sharedManager.managedObjectContext
    
    static func createSubject(name: String)->Subject? {
        let predicate = NSPredicate(format: "name like %@", "\(name)")
        
        let fetchItemWithSameId = NSFetchRequest(entityName: "Subject")
        
        fetchItemWithSameId.predicate = predicate
        let fetchedItems : NSArray?
        do {
            fetchedItems = try managedObjectContext.executeFetchRequest(fetchItemWithSameId)
            var subject: Subject?
            if (fetchedItems!.count == 0) {
                let entity = NSEntityDescription.entityForName("Subject", inManagedObjectContext: managedObjectContext)!
                subject = NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedObjectContext) as? Subject
            }else {
                subject = fetchedItems?.firstObject as? Subject
            }
            subject?.name = name
            return subject
        }catch let error as NSError{
            print("Fetch failed: \(error.localizedDescription)")
        }
        return nil
    }
}