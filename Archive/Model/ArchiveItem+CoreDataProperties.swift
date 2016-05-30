//
//  ArchiveItem+CoreDataProperties.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/4/16.
//  Copyright © 2016 Archive. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ArchiveItem {

    @NSManaged var desc: String?
    @NSManaged var identifier: String?
    @NSManaged var publicdate: NSDate?
    @NSManaged var publisher: String?
    @NSManaged var mediatype: String?
    @NSManaged var title: String?
    @NSManaged var isFavourite: NSNumber?
    @NSManaged var file: File?
    @NSManaged var collections: NSSet?
    @NSManaged var uploader: String?
    @NSManaged var subjects: NSSet?
    @NSManaged var authors: NSSet?
    
    var isFavorite: Bool {
        get {
            return (isFavourite?.boolValue == true)
        }
        set {
            isFavourite = NSNumber(bool: newValue)
        }
    }
    
    @NSManaged func addCollectionsObject(collection: ArchiveItem)
    @NSManaged func removeCollectionssObject(collection: ArchiveItem)

    @NSManaged func addSubjectsObject(subject: Subject)
    @NSManaged func removeSubjectsObject(subject: Subject)

    @NSManaged func addAuthorsObject(author: Author)
    @NSManaged func removeAuthorsObject(author: Author)
    @NSManaged func removeAllAuthors()
}
