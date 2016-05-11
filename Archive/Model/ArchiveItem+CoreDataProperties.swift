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
    
    var isFavorite: Bool {
        get {
            return (isFavourite?.boolValue == true)
        }
        set {
            isFavourite = NSNumber(bool: newValue)
        }
    }

}
