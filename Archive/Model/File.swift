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

    static let managedContext :NSManagedObjectContext = CoreDataStackManager.sharedManager.managedObjectContext
    
    static func createFile(dictionary: [String:AnyObject], archiveItem: ArchiveItem, managedObjectContext : NSManagedObjectContext, temporary: Bool)->File? {
        let predicate = NSPredicate(format: "self.archiveItem.identifier like %@", "\(archiveItem.identifier!)")
        
        let fetchItemWithSameId = NSFetchRequest(entityName: "File")
        
        fetchItemWithSameId.predicate = predicate
        let fetchedItems : NSArray?
        do {
            fetchedItems = try managedObjectContext.executeFetchRequest(fetchItemWithSameId)
            if (fetchedItems!.count == 0) {
                let entity = NSEntityDescription.entityForName("File", inManagedObjectContext: managedObjectContext)!
                let file = NSManagedObject(entity: entity, insertIntoManagedObjectContext: temporary ? nil : managedObjectContext) as! File

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
                        let chapter = Chapter.createChapter(doc["name"].stringValue,type: type, file: file, managedObjectContext: managedObjectContext, temporary: temporary)!
                        file.addChaptersObject(chapter)
                    }
                }
                return file
            }else {
                return fetchedItems?.firstObject as? File
            }
        }catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return nil
    }
}
