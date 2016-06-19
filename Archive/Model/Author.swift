//
//  Author.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/27/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import Foundation
import CoreData


class Author: NSManagedObject {
    
    static let managedObjectContext :NSManagedObjectContext = CoreDataStackManager.sharedManager.managedObjectContext
    
    static func createAuthor(name: String)->Author? {
        let predicate = NSPredicate(format: "name like %@", "\(name)")
        
        let fetchItemWithSameId = NSFetchRequest(entityName: "Author")
        
        fetchItemWithSameId.predicate = predicate
        let fetchedItems : NSArray?
        do {
            fetchedItems = try managedObjectContext.executeFetchRequest(fetchItemWithSameId)
            var author: Author?
            if (fetchedItems!.count == 0) {
                let entity = NSEntityDescription.entityForName("Author", inManagedObjectContext: managedObjectContext)!
                author = NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedObjectContext) as? Author
            }else {
                author = fetchedItems?.firstObject as? Author
            }
            author?.name = name
            return author
        }catch let error as NSError{
            print("Fetch failed: \(error.localizedDescription)")
        }
        return nil
    }
}
