//
//  ArchiveItem.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/4/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(ArchiveItem)
class ArchiveItem: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    static let managedContext :NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext


    static func createArchiveItemWithData(archiveItemData : ArchiveItemData, isFavourite: Bool) {
        let predicate = NSPredicate(format: "identifier like %@", "\(archiveItemData.identifier!)");
        
        let fetchItemWithSameId = NSFetchRequest(entityName: "ArchiveItem")
        
        fetchItemWithSameId.predicate = predicate
        let fetchedItems : NSArray?
        do {
            fetchedItems = try self.managedContext.executeFetchRequest(fetchItemWithSameId)
            if (fetchedItems!.count == 0) {
                let item = NSEntityDescription.insertNewObjectForEntityForName("ArchiveItem", inManagedObjectContext: managedContext) as! ArchiveItem
                item.identifier = archiveItemData.identifier
                item.desc = archiveItemData.desc
                item.title = archiveItemData.title
                item.isFavourite = isFavourite
                do {
                    try self.managedContext.save()
                }catch let error as NSError {
                    print("Save managedObjectContext failed: \(error.localizedDescription)")
                }
            }else if (fetchedItems!.count > 1) {
                print("ERROR DUPLICATED ARCHIVE ITEMS WITH ID : \(archiveItemData.identifier!)")
            }
            
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
    }
    
    static func archiveItem(identifer: String)->ArchiveItem? {
        let predicate = NSPredicate(format: "identifier like %@", "\(identifer)");
        
        let fetchItemWithSameId = NSFetchRequest(entityName: "ArchiveItem")
        
        fetchItemWithSameId.predicate = predicate
        let fetchedItems : NSArray?
        do {
            fetchedItems = try self.managedContext.executeFetchRequest(fetchItemWithSameId)
            if (fetchedItems!.count != 0) {
                return fetchedItems?.firstObject as? ArchiveItem
            }else {
                return nil
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func deleteItem(identifier: String)->Bool {
        if  let item = ArchiveItem.archiveItem(identifier) {
            managedContext.deleteObject(item)
            do {
                try managedContext.save()
                return true
            }catch {
                return false
            }
        }else {
            return false
        }
    }
    
    static func isFavouriteItem(identifer : String)->Bool {
        let predicate = NSPredicate(format: "identifier like %@ AND self.isFavourite == YES", "\(identifer)");
        
        let fetchItemWithSameId = NSFetchRequest(entityName: "ArchiveItem")
        
        fetchItemWithSameId.predicate = predicate
        let fetchedItems : NSArray?
        do {
            fetchedItems = try self.managedContext.executeFetchRequest(fetchItemWithSameId)
            if (fetchedItems!.count != 0) {
                 return true
            }else {
                return false
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
            return false
        }
    }

    static func deleteAllFavourites() {
        let predicate = NSPredicate(format: "self.isFavourite == YES");
        
        let fetchItemWithSameId = NSFetchRequest(entityName: "ArchiveItem")
        
        fetchItemWithSameId.predicate = predicate
        do {
            if let fetchedItems = try self.managedContext.executeFetchRequest(fetchItemWithSameId) as? [ArchiveItem] {
                for item in fetchedItems {
                    self.managedContext.deleteObject(item)
                }
                try self.managedContext.save()
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
    }
}
