//
//  File.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/9/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class File: NSObject, NSCoding {
    var identifier: String!
    var server: String?
    var directory: String?
    var subdirectory: String?
    var uploader: String?
    var collection: String?
    var scandata: String?
    var chapters: [Chapter]?
    
    init(identifier: String) {
        self.identifier = identifier.allowdStringForURL()
    }
    
    required init(coder aDecoder : NSCoder) {
        self.identifier = aDecoder.decodeObjectForKey("identifier") as! String
        self.server = aDecoder.decodeObjectForKey("server") as? String
        self.directory = aDecoder.decodeObjectForKey("directory") as? String
        self.subdirectory = aDecoder.decodeObjectForKey("subdirectory") as? String
        self.uploader = aDecoder.decodeObjectForKey("uploader") as? String
        self.collection = aDecoder.decodeObjectForKey("collection") as? String
        self.scandata = aDecoder.decodeObjectForKey("scandata") as? String
        self.chapters = aDecoder.decodeObjectForKey("chapters") as? [Chapter]

    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.identifier, forKey: "identifier")
        aCoder.encodeObject(self.server, forKey: "server")
        aCoder.encodeObject(self.directory, forKey: "directory")
        aCoder.encodeObject(self.subdirectory, forKey: "subdirectory")
        aCoder.encodeObject(self.uploader, forKey: "uploader")
        aCoder.encodeObject(self.collection, forKey: "collection")
        aCoder.encodeObject(self.scandata, forKey: "scandata")
        aCoder.encodeObject(self.chapters, forKey: "chapters")
    }
}
