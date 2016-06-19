//
//  File.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/4/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import SwiftyJSON

class File: NSManagedObject {
    
    static let managedObjectContext :NSManagedObjectContext = CoreDataStackManager.sharedManager.managedObjectContext
    
    static func createFile(dictionary: [String:AnyObject], archiveItem: ArchiveItem)->File? {
        let predicate = NSPredicate(format: "archiveItem.identifier == %@", archiveItem.identifier!)
        let request = NSFetchRequest(entityName: "File")
        request.predicate = predicate
        let fetchedItems : NSArray?
        var file: File?
        
        do {
            fetchedItems = try managedObjectContext.executeFetchRequest(request)
            if fetchedItems?.count == 0 {
                let entity = NSEntityDescription.entityForName("File", inManagedObjectContext: managedObjectContext)!
                file = NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedObjectContext) as? File
            }else {
                file = fetchedItems?.firstObject as? File
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
            return nil
        }
       
        if let file = file {
            let json = JSON(dictionary)
            file.server = json["server"].stringValue
            file.directory = json["dir"].stringValue
            let docs = json["files"].arrayValue
            file.archiveItem = archiveItem
            for doc in docs {
                let format = doc["format"].stringValue
                if format.containsString("Single Page Processed") {
                    var type = format.substringFromIndex((format.rangeOfString("Single Page Processed ")?.endIndex)!)
                    if type.containsString(" ZIP") {
                        type = type.substringToIndex((type.rangeOfString(" ZIP")?.startIndex)!)
                    }
                    let chapter = Chapter.createChapter(doc["name"].stringValue,type: type, file: file)!
                    file.addChaptersObject(chapter)
                }
            }
        }
        CoreDataStackManager.sharedManager.saveContext()
        return file
    }

    static func createFile(iafile: IAFile, managedObjectContext : NSManagedObjectContext)->File? {
        let predicate = NSPredicate(format: "archiveItem.identifier == %@", iafile.archiveItem!.identifier!)
        let request = NSFetchRequest(entityName: "File")
        request.predicate = predicate
        let fetchedItems : NSArray?
        var file: File?
        
        do {
            fetchedItems = try managedObjectContext.executeFetchRequest(request)
            if fetchedItems?.count == 0 {
                let entity = NSEntityDescription.entityForName("File", inManagedObjectContext: managedObjectContext)!
                file = NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedObjectContext) as? File
            }else {
                file = fetchedItems?.firstObject as? File
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
            return nil
        }
        
        if let file = file {
            file.server = iafile.server
            file.directory = iafile.directory
            let docs = iafile.chapters
            file.archiveItem = ArchiveItem.createArchiveItem(iafile.archiveItem!, managedObjectContext: managedObjectContext)
            for doc in docs {
                let chapter = Chapter.createChapter(doc, file: file)
                file.addChaptersObject(chapter!)
            }
        }
        CoreDataStackManager.sharedManager.saveContext()
        return file
    }

    func sortedChapters() -> [Chapter]? {
        return (self.chapters?.allObjects as! [Chapter]).sort({ $0.name < $1.name})
    }
}
