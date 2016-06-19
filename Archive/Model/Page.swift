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
    static func createPage(number: String, chapter: Chapter, isBookmarked: Bool, managedObjectContext:
        NSManagedObjectContext)->Page? {
        let predicate = NSPredicate(format: "(number == %@) AND (chapter.name == %@) AND (chapter.file.archiveItem.identifier == %@)", number, chapter.name!, chapter.file!.archiveItem!.identifier!)
        let request = NSFetchRequest(entityName: "Page")
        request.predicate = predicate
        let fetchedItems : NSArray?
        var page: Page?
        
        do {
            fetchedItems = try managedObjectContext.executeFetchRequest(request)
            if fetchedItems?.count == 0 {
                let entity = NSEntityDescription.entityForName("Page", inManagedObjectContext: managedObjectContext)!
                page = NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedObjectContext) as? Page
                
            }else {
                page = fetchedItems?.firstObject as? Page
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
            return nil
        }

        if let page = page {
            page.number = NSNumber(int: Int32(number)!)
            page.chapter = chapter
            chapter.addPagesObject(page)
            page.bookmarked = isBookmarked
        }
        return page
    }
    
    static func createPage(iaPage: IAPage, managedObjectContext: NSManagedObjectContext)->Page? {
       
        let predicate = NSPredicate(format: "(number == %d) AND (chapter.name == %@) AND (chapter.file.archiveItem.identifier == %@)", iaPage.number!, iaPage.chapter!.name!, iaPage.chapter!.file!.archiveItem!.identifier!)
        let request = NSFetchRequest(entityName: "Page")
        request.predicate = predicate
        let fetchedItems : NSArray?
        var page: Page?
        
        do {
            fetchedItems = try managedObjectContext.executeFetchRequest(request)
            if fetchedItems?.count == 0 {
                let entity = NSEntityDescription.entityForName("Page", inManagedObjectContext: managedObjectContext)!
                page = NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedObjectContext) as? Page

            }else {
                page = fetchedItems?.firstObject as? Page
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
            return nil
        }

        if let page = page {
            page.number = NSNumber(int: Int32(iaPage.number!))
            let chapter = Chapter.createChapter(iaPage.chapter!, file: File.createFile(iaPage.chapter!.file!, managedObjectContext: managedObjectContext)!)
            page.chapter = chapter
            chapter!.addPagesObject(page)
        }
        return page
    }


    static func isPageBookmarked(iaPage: IAPage)-> Bool {
        let predicate = NSPredicate(format: "(number == %d) AND (chapter.name == %@) AND (chapter.file.archiveItem.identifier == %@)", iaPage.number!, iaPage.chapter!.name!, iaPage.chapter!.file!.archiveItem!.identifier!)
        let request = NSFetchRequest(entityName: "Page")
        request.predicate = predicate
        let fetchedItems : NSArray?
        var page: Page?
        
        do {
            fetchedItems = try CoreDataStackManager.sharedManager.managedObjectContext.executeFetchRequest(request)
            if fetchedItems?.count == 0 {
                return false
            }else {
                page = fetchedItems?.firstObject as? Page
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
            return false
        }
        return page?.bookmarked ?? false
    }
    
    func markBookmarked(bookmarked: Bool) {
        self.bookmarked = bookmarked
    }
    
    func urlOfPage(scale: Int) -> String{
        let type = self.chapter!.type!.rawValue.lowercaseString
        return "https://\(self.chapter!.file!.server!)\(readerMethod)zip=\(self.chapter!.file!.directory!)/\(self.chapter!.subdirectory!)_\(type).zip&file=\(self.chapter!.subdirectory!)_\(type)/\(self.chapter!.subdirectory!)_\(String(format: "%04d", self.number!.intValue)).\(type)&scale=\(scale)".allowdStringForURL()
    }
}
