//
//  Chapter.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/4/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class Chapter: NSManagedObject {
    
    static let managedContext :NSManagedObjectContext = CoreDataStackManager.sharedManager.managedObjectContext
    
    static func createChapter(zipFile: String, type: String, file: File, managedObjectContext: NSManagedObjectContext, temporary: Bool)->Chapter? {
        let entity = NSEntityDescription.entityForName("Chapter", inManagedObjectContext: managedObjectContext)!
        let chapter = NSManagedObject(entity: entity, insertIntoManagedObjectContext: temporary ? nil : managedObjectContext) as! Chapter
        
        chapter.zipFile = zipFile
        if type == "JP2" || type == "JPEG" {
            chapter.type = .JP2
        }else if type == "TIFF" {
            chapter.type = .TIF
        }else if type == "PDF" {
            chapter.type = .PDF
        }
        chapter.scandata = (zipFile.substringToIndex((zipFile.rangeOfString("_\((chapter.type?.rawValue.lowercaseString)!).zip")?.startIndex)!)+"_scandata.xml")
        chapter.name = zipFile.substringToIndex((zipFile.rangeOfString("\((chapter.type?.rawValue.lowercaseString)!).zip")?.startIndex)!)
        chapter.subdirectory = zipFile.substringToIndex((zipFile.rangeOfString("_\((chapter.type?.rawValue.lowercaseString)!).zip")?.startIndex)!)
        chapter.isDownloaded = NSNumber(bool: false)
        chapter.isDownloading = NSNumber(bool: false)
        chapter.file = file
        return chapter
    }
    
    // Insert code here to add functionality to your managed object subclass
    
    func markDownloaded(downloaded: Bool) {
        do{
            if let managedObjectContext = self.managedObjectContext {
                self.isDownloaded = NSNumber(bool: downloaded)
                self.isDownloading = NSNumber(bool: false)
                try managedObjectContext.save()
                
            }else {
                let managedObjectContext = CoreDataStackManager.sharedManager.managedObjectContext
                managedObjectContext.insertObject(self.file!)
                managedObjectContext.insertObject(self.file!.archiveItem!)
                for chapter in (self.file!.chapters?.allObjects)! as! [Chapter] {
                    managedObjectContext.insertObject(chapter)
                    if let pages = chapter.pages?.allObjects as? [Page] {
                        for page in pages {
                            managedObjectContext.insertObject(page)
                        }
                    }
                }
                self.isDownloaded = NSNumber(bool: downloaded)
                self.isDownloading = NSNumber(bool: false)
                try CoreDataStackManager.sharedManager.managedObjectContext.save()
            }
        }catch let error as NSError {
            print("Error \(error.localizedDescription) can not save")
        }
    }

    func markInDownloadingState() {
        do{
            if let managedObjectContext = self.managedObjectContext {
                self.isDownloaded = NSNumber(bool: false)
                self.isDownloading = NSNumber(bool: true)
                try managedObjectContext.save()
                
            }else {
                let managedObjectContext = CoreDataStackManager.sharedManager.managedObjectContext
                managedObjectContext.insertObject(self.file!)
                managedObjectContext.insertObject(self.file!.archiveItem!)
                for chapter in (self.file!.chapters?.allObjects)! as! [Chapter] {
                    managedObjectContext.insertObject(chapter)
                    if let pages = chapter.pages?.allObjects as? [Page] {
                        for page in pages {
                            managedObjectContext.insertObject(page)
                        }
                    }
                }
                self.isDownloaded = NSNumber(bool: false)
                self.isDownloading = NSNumber(bool: true)
                try CoreDataStackManager.sharedManager.managedObjectContext.save()
            }
        }catch let error as NSError {
            print("Error \(error.localizedDescription) can not save")
        }
    }
    
    static func getDownloadedChapters() -> NSArray? {
        let predicate = NSPredicate(format: "isDownloaded == YES");
        
        let fetchRequest = NSFetchRequest(entityName: "Chapter")
        fetchRequest.predicate = predicate
        let fetchedItems : NSArray?
        do {
            fetchedItems = try self.managedContext.executeFetchRequest(fetchRequest)
            return fetchedItems
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func getChaptersInDownloadState() -> NSArray? {
        let predicate = NSPredicate(format: "isDownloading == YES");
        
        let fetchRequest = NSFetchRequest(entityName: "Chapter")
        fetchRequest.predicate = predicate
        let fetchedItems : NSArray?
        do {
            fetchedItems = try self.managedContext.executeFetchRequest(fetchRequest)
            return fetchedItems
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
            return nil
        }
    }
    
}
