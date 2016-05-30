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
            var item: ArchiveItem?
            if (fetchedItems!.count == 0) {
                let entity = NSEntityDescription.entityForName("ArchiveItem", inManagedObjectContext: managedObjectContext)!
                item = NSManagedObject(entity: entity, insertIntoManagedObjectContext: temporary ? nil : managedObjectContext) as? ArchiveItem
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
                item.deleteSubjects()
                if let subjects = dictionary["subject"] as? [String] {
                    for subject in subjects {
                        item.addSubjectsObject(Subject.createSubject(subject, managedObjectContext: managedObjectContext, temporary: temporary)!)
                    }
                }else if let subject = dictionary["subject"] as? String {
                    let obj = Subject.createSubject(subject, managedObjectContext: managedObjectContext, temporary: temporary)
                    item.addSubjectsObject(obj!)
                }
                
                item.deleteAuthors()

                if let authors = dictionary["creator"] as? [String] {
                    for author in authors {
                        item.addAuthorsObject(Author.createAuthor(author, managedObjectContext: managedObjectContext, temporary: temporary)!)
                    }
                }else if let author = dictionary["creator"] as? String {
                    let obj = Author.createAuthor(author, managedObjectContext: managedObjectContext, temporary: temporary)
                    item.addAuthorsObject(obj!)
                }

            }
            do{
                if !temporary {
                    try managedObjectContext.save()
                }
            }catch let error as NSError {
                print("Save managedObjectContext failed: \(error.localizedDescription)")
            }
            return item
        }catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return nil
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
                    item.isFavorite = false
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
            let collection = ArchiveItem.createArchiveItem(collectionDict, managedObjectContext: managedObjectContext!, temporary: temporary)
            self.addCollectionsObject(collection!)
            if !temporary {
                try managedObjectContext!.save()
            }
        }catch {
        }
    }
    
    func setupUploader(uploader: String) {
        do {
            var managedObjectContext: NSManagedObjectContext?
            var temporary = true
            if let ctxt = self.managedObjectContext {
                managedObjectContext = ctxt
                temporary = false
            }else {
                managedObjectContext = try CoreDataStackManager.sharedManager.createPrivateQueueContext()
            }
            self.uploader = uploader
            if !temporary {
                try managedObjectContext!.save()
            }
        }catch {
        }
    }
    
    func setupFile(dictionary: [String:AnyObject]) {
        if let managedObjectContext = self.managedObjectContext {
            File.createFile(dictionary, archiveItem: self, managedObjectContext: managedObjectContext, temporary: false)
        }else {
            do{
                let managedObjectContext = try CoreDataStackManager.sharedManager.createPrivateQueueContext()
                if let file = File.createFile(dictionary, archiveItem: self, managedObjectContext: managedObjectContext, temporary: !(self.isFavourite!.boolValue)) {
                    self.file = file
                    managedObjectContext.reset()
                }
            }catch let error as NSError{
                print("could not create managed object context \(error.localizedDescription)")
            }
        }
    }
}
