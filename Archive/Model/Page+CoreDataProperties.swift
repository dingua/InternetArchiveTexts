//
//  Page+CoreDataProperties.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/12/16.
//  Copyright © 2016 Archive. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Page {

    @NSManaged var number: String?
    @NSManaged var isBookmarked: NSNumber?
    @NSManaged var chapter: Chapter?

    var bookmarked: Bool {
        get{
            return (isBookmarked?.boolValue == true)
        }
        set {
            isBookmarked = NSNumber(bool: newValue)
        }
    }
}
