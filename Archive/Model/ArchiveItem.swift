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
    
    static let managedObjectContext :NSManagedObjectContext = CoreDataStackManager.sharedManager.managedObjectContext
  
    static func createArchiveItem(dictionary: [String:AnyObject])->ArchiveItem? {
        return ArchiveItem.createArchiveItem(dictionary, save: true)
    }
    
    
    static func createArchiveItem(dictionary: [String:AnyObject], save: Bool )->ArchiveItem? {
        let predicate = NSPredicate(format: "identifier like %@", "\(dictionary["identifier"]!)");
        
        let fetchItemWithSameId = NSFetchRequest(entityName: "ArchiveItem")
        
        fetchItemWithSameId.predicate = predicate
        let fetchedItems : NSArray?
        do {
            fetchedItems = try managedObjectContext.executeFetchRequest(fetchItemWithSameId)
            var item: ArchiveItem?
            if (fetchedItems!.count == 0) {
                let entity = NSEntityDescription.entityForName("ArchiveItem", inManagedObjectContext: managedObjectContext)!
                item = NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedObjectContext) as? ArchiveItem
                item!.isFavourite = NSNumber(bool: false)
            }else {
                item = fetchedItems?.firstObject as? ArchiveItem
            }
            if let item = item {
                if let identifier = dictionary["identifier"] as? String {
                    item.identifier = identifier
                }
                if let description = dictionary["description"] as? String {
                    item.desc = description
                }
                if let title = dictionary["title"] as? String {
                    item.title = title
                }
                if let mediatype = dictionary["mediatype"] as? String {
                    item.mediatype = mediatype
                }
                if let uploader = dictionary["uploader"] as? String {
                    item.uploader = uploader
                }
                
                if item.subjects?.count == 0 {
                    if let subjects = dictionary["subject"] as? [String] {
                        for subject in subjects {
                            item.addSubjectsObject(Subject.createSubject(subject)!)
                        }
                    }else if let subject = dictionary["subject"] as? String {
                        let obj = Subject.createSubject(subject)
                        item.addSubjectsObject(obj!)
                    }
                }
                
                if item.authors?.count == 0 {
                    if let authors = dictionary["creator"] as? [String] {
                        for author in authors {
                            item.addAuthorsObject(Author.createAuthor(author)!)
                        }
                    }else if let author = dictionary["creator"] as? String {
                        let obj = Author.createAuthor(author)
                        item.addAuthorsObject(obj!)
                    }
                }
            }
            
            if save {
                CoreDataStackManager.sharedManager.saveContext()
            }

            return item
        }catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return nil
    }
    
    
    static func createArchiveItem(archiveItem: IAArchiveItem, managedObjectContext : NSManagedObjectContext)->ArchiveItem? {
        let predicate = NSPredicate(format: "identifier like %@", archiveItem.identifier!);
        
        let fetchItemWithSameId = NSFetchRequest(entityName: "ArchiveItem")
        
        fetchItemWithSameId.predicate = predicate
        let fetchedItems : NSArray?
        do {
            fetchedItems = try managedObjectContext.executeFetchRequest(fetchItemWithSameId)
            var item: ArchiveItem?
            if (fetchedItems!.count == 0) {
                let entity = NSEntityDescription.entityForName("ArchiveItem", inManagedObjectContext: managedObjectContext)!
                item = NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedObjectContext) as? ArchiveItem
                item!.isFavourite = NSNumber(bool: false)
            }else {
                item = fetchedItems?.firstObject as? ArchiveItem
            }
            if let item = item {
                if let identifier = archiveItem.identifier {
                    item.identifier = identifier
                }
                if let description = archiveItem.desc {
                    item.desc = description
                }
                if let title = archiveItem.title {
                    item.title = title
                }
                if let mediatype = archiveItem.mediatype {
                    item.mediatype = mediatype
                }
                if let uploader = archiveItem.uploader {
                    item.uploader = uploader
                }
                for subject in archiveItem.subjects {
                    let obj = Subject.createSubject(subject)
                    item.addSubjectsObject(obj!)
                }
                for author in archiveItem.authors {
                    let obj = Author.createAuthor(author)
                    item.addAuthorsObject(obj!)
                }
            }
            CoreDataStackManager.sharedManager.saveContext()
            return item
        }catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return nil
    }
    
    static func isFavourite(itemIdentifier: String)->Bool {
        let predicate = NSPredicate(format: "identifier like %@", itemIdentifier)
        let request = NSFetchRequest(entityName: "ArchiveItem")
        request.predicate = predicate
        request.resultType = .DictionaryResultType
        request.propertiesToFetch = ["isFavourite"]
        
        let fetchedItems : NSArray?
        do {
            fetchedItems = try managedObjectContext.executeFetchRequest(request)
            if fetchedItems?.count == 0 {
                return false
            }else {
                let item = fetchedItems?.firstObject as? [String:AnyObject]
                return  item?["isFavourite"]?.boolValue ?? false
            }
        }catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return false
    }
    
    func deleteAuthors() {
        if let authors = self.authors?.allObjects {
            for author in authors {
                self.removeAuthorsObject(author as! Author)
            }
        }
    }
    
    func deleteSubjects() {
        if let subjects = self.subjects?.allObjects {
            for subject in subjects {
                self.removeSubjectsObject(subject as! Subject)
            }
        }
    }
    
    func markAsFavourite(favourite: Bool) {
        self.isFavourite = NSNumber(bool: favourite)
    }
    
    
    static func deleteAllFavourites() {
        let predicate = NSPredicate(format: "self.isFavourite == YES");
        
        let fetchItemWithSameId = NSFetchRequest(entityName: "ArchiveItem")
        
        fetchItemWithSameId.predicate = predicate
        do {
            if let fetchedItems = try managedObjectContext.executeFetchRequest(fetchItemWithSameId) as? [ArchiveItem] {
                for item in fetchedItems {
                    item.isFavorite = false
                }
                CoreDataStackManager.sharedManager.saveContext()
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
    
    func addCollection(collectionDict: [String:AnyObject]) {
        do {
            var managedObjectContext: NSManagedObjectContext?
            var temporary = true
            if let ctxt = self.managedObjectContext {
                managedObjectContext = ctxt
                temporary = false
            }else {
                managedObjectContext = try CoreDataStackManager.sharedManager.createPrivateQueueContext()
            }
            let collection = ArchiveItem.createArchiveItem(collectionDict)
            self.addCollectionsObject(collection!)
            if !temporary {
                try managedObjectContext!.save()
            }
        }catch {
        }
    }
    
    func setupUploader(uploader: String) {
        self.uploader = uploader
        do {
            if let managedObjectContext = self.managedObjectContext {
                try managedObjectContext.save()
            }
        }catch let error as NSError{
            print("ERROR Saving context \(error.localizedDescription)")
        }
    }
    
    func setupFile(dictionary: [String:AnyObject]) {
        if let file = File.createFile(dictionary, archiveItem: self) {
            self.file = file
        }
    }
}
