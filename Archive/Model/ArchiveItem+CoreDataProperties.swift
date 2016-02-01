//
//  ArchiveItem+CoreDataProperties.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/8/16.
//  Copyright © 2016 Archive. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ArchiveItem {

    @NSManaged var identifier: String?
    @NSManaged var publicdate: NSDate?
    @NSManaged var publisher: String?
    @NSManaged var title: String?
    @NSManaged var desc: String?
    @NSManaged var formats: NSSet?

}
