//
//  File+CoreDataProperties.swift
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

extension File {

    @NSManaged var server: String?
    @NSManaged var directory: String?
    @NSManaged var chapters: NSSet?
    @NSManaged var archiveItem: ArchiveItem?
   
    @NSManaged func addChaptersObject(chapter: Chapter)
    @NSManaged func removeChaptersObject(chapter: Chapter)
}
