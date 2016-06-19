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
    static let managedObjectContext :NSManagedObjectContext = CoreDataStackManager.sharedManager.managedObjectContext

    static func createChapter(zipFile: String, type: String, file: File)->Chapter? {
        var chapType: Type?
        if type == "JP2" {
            chapType = .JP2
        }else if type == "JPEG" {
            chapType = .JPG
        }else if type == "TIFF" {
            chapType = .TIF
        }else if type == "PDF" {
            chapType = .PDF
        }else if type == "JP2 Tar" {
            chapType = .JP2TAR
        }
        let fileExtension = (chapType == .JP2TAR) ? "tar" : "zip"
        let name = zipFile.substringToIndex((zipFile.rangeOfString("\((chapType?.rawValue.lowercaseString)!).\(fileExtension)")?.startIndex)!)
        let predicate = NSPredicate(format: "(name == %@) AND (file.archiveItem.identifier == %@)", name, file.archiveItem!.identifier!)
        let request = NSFetchRequest(entityName: "Chapter")
        request.predicate = predicate
        let fetchedItems : NSArray?
        var chapter: Chapter?
       
        do {
            fetchedItems = try managedObjectContext.executeFetchRequest(request)
            if fetchedItems?.count == 0 {
                let entity = NSEntityDescription.entityForName("Chapter", inManagedObjectContext: managedObjectContext)!
                chapter = NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedObjectContext) as? Chapter
            }else {
                chapter = fetchedItems!.firstObject as? Chapter
            }
        }catch{}
        
        if let chapter = chapter {
            chapter.type = chapType
            chapter.zipFile = zipFile
            chapter.scandata = (zipFile.substringToIndex((zipFile.rangeOfString("_\((chapter.type?.rawValue.lowercaseString)!).\(fileExtension)")?.startIndex)!)+"_scandata.xml")
            chapter.name = zipFile.substringToIndex((zipFile.rangeOfString("\((chapter.type?.rawValue.lowercaseString)!).\(fileExtension)")?.startIndex)!)
            chapter.subdirectory = zipFile.substringToIndex((zipFile.rangeOfString("_\((chapter.type?.rawValue.lowercaseString)!).\(fileExtension)")?.startIndex)!)
            chapter.file = file
        }
        CoreDataStackManager.sharedManager.saveContext()
        return chapter
    }
    
    static func createChapter(chap: IAChapter,file: File)->Chapter? {
       
        let predicate = NSPredicate(format: "(name == %@) AND (file.archiveItem.identifier == %@)", chap.name!, file.archiveItem!.identifier!)
        let request = NSFetchRequest(entityName: "Chapter")
        request.predicate = predicate
        let fetchedItems : NSArray?
        var chapter: Chapter?
        
        do {
            fetchedItems = try managedObjectContext.executeFetchRequest(request)
            if fetchedItems?.count == 0 {
                let entity = NSEntityDescription.entityForName("Chapter", inManagedObjectContext: managedObjectContext)!
                chapter = NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedObjectContext) as? Chapter
            }else {
                chapter = fetchedItems!.firstObject as? Chapter
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
            return nil
        }
        if let chapter = chapter {
            chapter.zipFile = chap.zipFile
            chapter.type = chap.type
            chapter.scandata = chap.scandata
            chapter.name = chap.name
            chapter.subdirectory = chap.subdirectory
            chapter.file = file
        }
        CoreDataStackManager.sharedManager.saveContext()
        return chapter
    }
    
    // Insert code here to add functionality to your managed object subclass
    
    func markDownloaded(downloaded: Bool) {
        self.isDownloaded = NSNumber(bool: downloaded)
        self.isDownloading = NSNumber(bool: false)
        CoreDataStackManager.sharedManager.saveContext()
    }

    func markInDownloadingState() {
        self.isDownloaded = NSNumber(bool: false)
        self.isDownloading = NSNumber(bool: true)
        CoreDataStackManager.sharedManager.saveContext()
    }
    
    static func getDownloadedChapters() -> NSArray? {
        let predicate = NSPredicate(format: "isDownloaded == YES");
        
        let fetchRequest = NSFetchRequest(entityName: "Chapter")
        fetchRequest.predicate = predicate
        let fetchedItems : NSArray?
        do {
            fetchedItems = try managedObjectContext.executeFetchRequest(fetchRequest)
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
            fetchedItems = try managedObjectContext.executeFetchRequest(fetchRequest)
            return fetchedItems
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func chapterDownloadStatus(chapterName: String, itemIdentifier: String) -> (isDownloaded:Bool,isDownloading:Bool) {
        let predicate = NSPredicate(format: "name like %@ AND file.archiveItem.identifier like %@", chapterName, itemIdentifier)
        let request = NSFetchRequest(entityName: "Chapter")
        request.predicate = predicate
        request.resultType = .DictionaryResultType
        request.propertiesToFetch = ["isDownloaded","isDownloading"]
        
        let fetchedItems : NSArray?
        do {
            fetchedItems = try managedObjectContext.executeFetchRequest(request)
            if fetchedItems?.count == 0 {
                return (false, false)
            }else {
                let item = fetchedItems?.firstObject as? [String:AnyObject]
                return  (item?["isDownloaded"]?.boolValue ?? false, item?["isDownloading"]?.boolValue ?? false)
            }
        }catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return (false, false)
    }
}
