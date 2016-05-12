//
//  Chapter+CoreDataProperties.swift
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

enum Type: String {
    case JP2
    case TIF
    case PDF
}

extension Chapter {

    @NSManaged var name: String?
    @NSManaged var zipFile: String?
    @NSManaged var subdirectory: String?
    @NSManaged var typeValue: String?
    @NSManaged var numberOfPages: NSNumber?
    @NSManaged var file: File?
    @NSManaged var isDownloaded: NSNumber?
    @NSManaged var isDownloading: NSNumber?
    @NSManaged var scandata: String?
    
    var type: Type? {
        get {
            return Type(rawValue: typeValue!)
        }
        set {
            typeValue = newValue!.rawValue
        }
    }
}
