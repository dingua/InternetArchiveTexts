//
//  CoreDataStackManager.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/10/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStackManager {
    // MARK: Properties
    
    static let sharedManager = CoreDataStackManager()
    static let applicationDocumentsDirectoryName = "com.example.apple-samplecode.Earthquakes"
    static let mainStoreFileName = "SingleViewCoreData.sqlite"
    static let errorDomain = "CoreDataStackManager"
    
    /// The managed object model for the application.
    lazy var managedObjectModel: NSManagedObjectModel = {
        /*
         This property is not optional. It is a fatal error for the application
         not to be able to find and load its model.
         */
        let modelURL = NSBundle.mainBundle().URLForResource("Archive", withExtension: "momd")!
        
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    /// Primary persistent store coordinator for the application.
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        /*
         This implementation creates and return a coordinator, having added the
         store for the application to it. (The directory for the store is created, if necessary.)
         */
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        do {
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
            ]
            
            try persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: self.storeURL, options: options)
        }
        catch {
            fatalError("Could not add the persistent store: \(error).")
        }
        
        return persistentStoreCoordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        
        let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        moc.persistentStoreCoordinator = self.persistentStoreCoordinator
        moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        moc.undoManager = nil
        return moc
    }()

    

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.huawei.ott.Archive" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    /// URL for the main Core Data store file.
    lazy var storeURL: NSURL = {
        return self.applicationDocumentsDirectory.URLByAppendingPathComponent(mainStoreFileName)
    }()
    
    
    // Creates a new Core Data stack and returns a managed object context associated with a private queue.
    func createPrivateQueueContext() throws -> NSManagedObjectContext {
        
        // Stack uses the same store and model, but a new persistent store coordinator and context.
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: CoreDataStackManager.sharedManager.managedObjectModel)
        
        /*
         Attempting to add a persistent store may yield an error--pass it out of
         the function for the caller to deal with.
         */
        try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: CoreDataStackManager.sharedManager.storeURL, options: nil)
        
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        
        context.performBlockAndWait() {
            
            context.parentContext = self.managedObjectContext
            
            // Avoid using default merge policy in multi-threading environment:
            // when we delete (and save) a record in one context,
            // and try to save edits on the same record in the other context before merging the changes,
            // an exception will be thrown because Core Data by default uses NSErrorMergePolicy.
            // Setting a reasonable mergePolicy is a good practice to avoid that kind of exception.
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            // In OS X, a context provides an undo manager by default
            // Disable it for performance benefit
            context.undoManager = nil
        }
        
        return context
    }
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}