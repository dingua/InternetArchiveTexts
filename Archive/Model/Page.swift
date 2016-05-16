//
//  Page.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/12/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import Foundation
import CoreData


class Page: NSManagedObject {
    
    // Insert code here to add functionality to your managed object subclass
    static func createPage(number: String, chapter: Chapter, isBookmarked: Bool, managedObjectContext: NSManagedObjectContext, temporary: Bool)->Page? {
        let predicate = NSPredicate(format: "number like %@ And chapter.name like %@", "\(number)", "\(chapter.name!)")
        let fetchItemWithSameId = NSFetchRequest(entityName: "Page")
        fetchItemWithSameId.predicate = predicate
        let fetchedItems : NSArray?
        do {
            fetchedItems = try managedObjectContext.executeFetchRequest(fetchItemWithSameId)
            if (fetchedItems!.count == 0) {
                let entity = NSEntityDescription.entityForName("Page", inManagedObjectContext: managedObjectContext)!
                let page = NSManagedObject(entity: entity, insertIntoManagedObjectContext: temporary ? nil : managedObjectContext) as! Page
                page.number = number
                page.chapter = chapter
                chapter.addPagesObject(page)
                page.bookmarked = isBookmarked
                do{
                    if !temporary {
                        try managedObjectContext.save()
                    }
                }catch let error as NSError {
                    print("Save managedObjectContext failed: \(error.localizedDescription)")
                }
                return page
            }else {
                return fetchedItems?.firstObject as? Page
            }
        }catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return nil
    }
    
    func markBookmarked(bookmarked: Bool) {
        do{
            if let managedObjectContext = self.managedObjectContext {
                self.bookmarked = bookmarked
                try managedObjectContext.save()
            }else {
                let managedObjectContext = CoreDataStackManager.sharedManager.managedObjectContext
                managedObjectContext.insertObject(self.chapter!)
                managedObjectContext.insertObject(self.chapter!.file!)
                managedObjectContext.insertObject(self.chapter!.file!.archiveItem!)
                for chapter in (self.chapter!.file!.chapters?.allObjects)! as! [Chapter] {
                    managedObjectContext.insertObject(chapter)
                    if let pages = chapter.pages?.allObjects as? [Page] {
                        for page in pages {
                            managedObjectContext.insertObject(page)
                        }
                    }
                }
                self.bookmarked = bookmarked
                try CoreDataStackManager.sharedManager.managedObjectContext.save()
            }
        }catch let error as NSError {
            print("Error \(error.localizedDescription) can not save")
        }
        
    }
    
    func urlOfPage(scale: Int) -> String{
        let type = self.chapter!.type!.rawValue.lowercaseString
        return "https://\(self.chapter!.file!.server!)\(readerMethod)zip=\(self.chapter!.file!.directory!)/\(self.chapter!.subdirectory!)_\(type).zip&file=\(self.chapter!.subdirectory!)_\(type)/\(self.chapter!.subdirectory!)_\(String(format: "%04d", Int(self.number!)!)).\(type)&scale=\(scale)"
    }
}
