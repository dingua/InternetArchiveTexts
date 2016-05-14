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
    
    static let managedContext :NSManagedObjectContext = CoreDataStackManager.sharedManager.managedObjectContext
    
    static func createArchiveItem(dictionary: [String:AnyObject], managedObjectContext : NSManagedObjectContext, temporary: Bool)->ArchiveItem? {
        let predicate = NSPredicate(format: "identifier like %@", "\(dictionary["identifier"]!)");
        
        let fetchItemWithSameId = NSFetchRequest(entityName: "ArchiveItem")
        
        fetchItemWithSameId.predicate = predicate
        let fetchedItems : NSArray?
        do {
            fetchedItems = try self.managedContext.executeFetchRequest(fetchItemWithSameId)
            if (fetchedItems!.count == 0) {
                let entity = NSEntityDescription.entityForName("ArchiveItem", inManagedObjectContext: managedObjectContext)!
                let item = NSManagedObject(entity: entity, insertIntoManagedObjectContext: temporary ? nil : managedObjectContext) as! ArchiveItem
                item.identifier = dictionary["identifier"] as? String
                item.desc = dictionary["description"] as? String
                item.title = dictionary["title"] as? String
                item.mediatype = dictionary["mediatype"] as? String
                item.isFavourite = NSNumber(bool: false)
                do{
                    if !temporary {
                        try managedObjectContext.save()
                    }
                }catch let error as NSError {
                    print("Save managedObjectContext failed: \(error.localizedDescription)")
                }
                return item
            }else {
                return fetchedItems?.firstObject as? ArchiveItem
            }
        }catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return nil
    }

    func markAsFavourite(favourite: Bool) {
        do{
            if let managedObjectContext = self.managedObjectContext {
                self.isFavourite = NSNumber(bool: favourite)
                try managedObjectContext.save()
                
            }else {
                let managedObjectContext = CoreDataStackManager.sharedManager.managedObjectContext
                managedObjectContext.insertObject(self)
                if let file = self.file {
                    managedObjectContext.insertObject(file)
                    if let chapters = file.chapters {
                        for chapter in chapters.allObjects {
                            managedObjectContext.insertObject(chapter as! Chapter)
                        }
                    }
                }
                self.isFavourite = NSNumber(bool: favourite)
                try CoreDataStackManager.sharedManager.managedObjectContext.save()
            }
        }catch let error as NSError {
            print("Error \(error.localizedDescription) can not save")
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
    
    func hasDownloadedChapter()->Bool {
        for chapter in (self.file?.chapters?.allObjects as? [Chapter])!{
                if chapter.isDownloaded!.boolValue == true {
                    return true
            }
        }
        return false
    }
}
