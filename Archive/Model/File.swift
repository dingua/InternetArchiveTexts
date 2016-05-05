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
    
    
    static func createFileWithData(fileData : FileData) {
        let predicate = NSPredicate(format: "identifier like %@", "\(fileData.identifier!)");
        
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
                }
                do {
                    try self.managedContext.save()
                }catch let error as NSError {
                    print("Save managedObjectContext failed: \(error.localizedDescription)")
                }
            }else if (fetchedItems!.count > 1) {
                print("ERROR DUPLICATED FILE ITEMS WITH ID : \(fileData.identifier!)")
            }
            
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
    }

}
