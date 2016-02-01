//
//  ArchiveItem.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/8/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import Foundation
import CoreData

@objc(ArchiveItem)
class ArchiveItem: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    static let managedContext :NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
//    var managedObjectContext = UIApplication.sharedApplication().delegate().managedObjectContext()
    
    static func createArchiveItemWithDictionary(dictionary:NSDictionary) {
        let predicate = NSPredicate(format: "identifier like %@", "\(dictionary.valueForKey("identifier")!)");
        
       let fetchItemWithSameId = NSFetchRequest(entityName: "ArchiveItem")
        
        fetchItemWithSameId.predicate = predicate
        let fetchedItems : NSArray?
        do {
            fetchedItems = try self.managedContext.executeFetchRequest(fetchItemWithSameId)
            if (fetchedItems!.count == 0) {
                let item = NSEntityDescription.insertNewObjectForEntityForName("ArchiveItem", inManagedObjectContext: managedContext) as! ArchiveItem
                item.identifier = dictionary.valueForKey("identifier") as? String
                item.desc = dictionary.valueForKey("description") as? String
                item.title = dictionary.valueForKey("title") as? String
                do {
                    try self.managedContext.save()
                }catch let error as NSError {
                    print("Save managedObjectContext failed: \(error.localizedDescription)")
                }
            }else if (fetchedItems!.count > 1) {
                print("ERROR DUPLICATED ARCHIVE ITEMS WITH ID : \(dictionary.valueForKey("identifier"))")
            }

        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
    }

}
