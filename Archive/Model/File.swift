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

class File: NSManagedObject {

    static let managedContext :NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    static func createFileWithData(fileData : FileData)->File? {
        let predicate = NSPredicate(format: "self.archiveItem.identifier like %@", "\(fileData.identifier!)");
        
        let fetchItemWithSameId = NSFetchRequest(entityName: "File")
        
        fetchItemWithSameId.predicate = predicate
        let fetchedItems : NSArray?
        do {
            fetchedItems = try self.managedContext.executeFetchRequest(fetchItemWithSameId)
            if (fetchedItems!.count == 0) {
                let item = NSEntityDescription.insertNewObjectForEntityForName("File", inManagedObjectContext: managedContext) as! File
                item.server = fileData.server
                item.directory = fileData.directory
                if let archiveItem = ArchiveItem.archiveItem(fileData.identifier) {
                    item.archiveItem = archiveItem
                }else {
                    if let archiveItem =  ArchiveItem.createArchiveItemWithData(fileData.archiveItem!, isFavourite: false) {
                        item.archiveItem = archiveItem
                    }
                    
                }
                
                item.chapters?.setByAddingObjectsFromArray(fileData.chapters!.map({Chapter.createChapter($0, file: item)!}))

                do {
                    try self.managedContext.save()
                    return item
                }catch let error as NSError {
                    print("Save managedObjectContext failed: \(error.localizedDescription)")
                }
            }else {
                print("ERROR DUPLICATED FILE ITEMS WITH ID : \(fileData.identifier!)")
                return fetchedItems?.firstObject as? File
            }
            
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return nil
    }

}
