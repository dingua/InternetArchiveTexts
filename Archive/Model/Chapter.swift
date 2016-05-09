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

    static let managedContext :NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

// Insert code here to add functionality to your managed object subclass

    static func markChapterDownloaded(chapterName: String, itemId: String) {
        let predicate = NSPredicate(format: "name like %@", "\(chapterName)");
        
        let fetchRequest = NSFetchRequest(entityName: "Chapter")
        fetchRequest.predicate = predicate
        let fetchedItems : NSArray?
        do {
            fetchedItems = try self.managedContext.executeFetchRequest(fetchRequest)
            if (fetchedItems!.count != 0) {
                let chapter = fetchedItems?.firstObject as! Chapter
                chapter.isDownloaded = NSNumber(bool: true)
                chapter.isDownloading = NSNumber(bool: false)
               try self.managedContext.save()
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
    }
    
    static func markChapterDownloadingState(chapterName: String, itemId: String) {
        let predicate = NSPredicate(format: "name like %@", "\(chapterName)");
        
        let fetchRequest = NSFetchRequest(entityName: "Chapter")
        fetchRequest.predicate = predicate
        let fetchedItems : NSArray?
        do {
            fetchedItems = try self.managedContext.executeFetchRequest(fetchRequest)
            if (fetchedItems!.count != 0) {
                let chapter = fetchedItems?.firstObject as! Chapter
                chapter.isDownloaded = NSNumber(bool: false)
                chapter.isDownloading = NSNumber(bool: true)
                try self.managedContext.save()
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
    }
    

    static func createChapter(chapterData: ChapterData, file: File)->Chapter? {
        let predicate = NSPredicate(format: "name like %@", "\(chapterData.name!)");
        
        let fetchItemWithSameId = NSFetchRequest(entityName: "Chapter")
        
        fetchItemWithSameId.predicate = predicate
        let fetchedItems : NSArray?
        do {
            fetchedItems = try self.managedContext.executeFetchRequest(fetchItemWithSameId)
            if (fetchedItems!.count == 0) {
                let item = NSEntityDescription.insertNewObjectForEntityForName("Chapter", inManagedObjectContext: managedContext) as! Chapter
                item.name = chapterData.name
                item.zipFile = chapterData.zipFile
                item.subdirectory = chapterData.subdirectory
                item.type = chapterData.type?.rawValue
                item.numberOfPages = chapterData.numberOfPages
                item.isDownloaded = NSNumber(bool: false)
                item.isDownloading = NSNumber(bool: false)
                item.file = file
                do {
                    try self.managedContext.save()
                    return item
                }catch let error as NSError {
                    print("Save managedObjectContext failed: \(error.localizedDescription)")
                }
            }else if (fetchedItems!.count > 1) {
                print("ERROR DUPLICATED CHAPTERS WITH name : \(chapterData.name!)")
            }
            
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return nil
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

    static func isDownloadedChapter(chapterName : String)->Bool {
        let predicate = NSPredicate(format: "name like %@ AND isDownloaded == YES", "\(chapterName)");
        
        let fetchItemWithSameId = NSFetchRequest(entityName: "Chapter")
        
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

    
}
