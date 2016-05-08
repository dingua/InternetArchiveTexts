//
//  Chapter.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/28/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
enum FileType: String {
    case JP2 = "JP2"
    case TIFF = "TIF"
    case PDF = "PDF"
}

class ChapterData: NSObject, NSCoding {
    var name: String?
    var zipFile: String!
    var subdirectory: String?
    var scandata: String?
    var type: FileType?
    var numberOfPages : Int?
    
    init (zipFile: String) {
        self.zipFile = zipFile.allowdStringForURL()
        self.scandata = zipFile.substringToIndex((zipFile.rangeOfString("_jp2.zip")?.startIndex)!)+"_scandata.xml".allowdStringForURL()
        self.name = zipFile.substringToIndex((zipFile.rangeOfString("_jp2.zip")?.startIndex)!).allowdStringForURL()
    }
    init (zipFile: String, type: String) {
        self.zipFile = zipFile.allowdStringForURL()
         if type == "JP2" || type == "JPEG" {
            self.type = .JP2
        }else if type == "TIFF" {
            self.type = .TIFF
        }else if type == "PDF" {
            self.type = .PDF
        }
        self.scandata = (zipFile.substringToIndex((zipFile.rangeOfString("_\((self.type?.rawValue.lowercaseString)!).zip")?.startIndex)!)+"_scandata.xml").allowdStringForURL()
        self.name = zipFile.substringToIndex((zipFile.rangeOfString("\((self.type?.rawValue.lowercaseString)!).zip")?.startIndex)!).allowdStringForURL()
        self.subdirectory = zipFile.substringToIndex((zipFile.rangeOfString("_\((self.type?.rawValue.lowercaseString)!).zip")?.startIndex)!).allowdStringForURL()
    }

    init(chapter: Chapter) {
        self.name = chapter.name
        self.zipFile = chapter.zipFile
        self.scandata = chapter.scandata
        self.type = FileType(rawValue: chapter.type!)
        self.numberOfPages = chapter.numberOfPages?.integerValue
        self.subdirectory = chapter.subdirectory
        self.scandata = (zipFile.substringToIndex((zipFile.rangeOfString("_\((self.type?.rawValue.lowercaseString)!).zip")?.startIndex)!)+"_scandata.xml").allowdStringForURL()
    }
    
    required init(coder aDecoder : NSCoder) {
        self.name = (aDecoder.decodeObjectForKey("name") as? String)
        self.zipFile = aDecoder.decodeObjectForKey("zipFile") as! String
        self.scandata = aDecoder.decodeObjectForKey("scandata") as? String
        self.type = FileType(rawValue: aDecoder.decodeObjectForKey("type") as! String)
        self.numberOfPages =  aDecoder.decodeObjectForKey("numberOfPages") as? Int
        self.subdirectory = aDecoder.decodeObjectForKey("subdirectory") as? String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.zipFile, forKey: "zipFile")
        aCoder.encodeObject(self.scandata, forKey: "scandata")
        aCoder.encodeObject(self.type?.rawValue, forKey: "type")
        aCoder.encodeObject(self.numberOfPages, forKey: "numberOfPages")
        aCoder.encodeObject(self.subdirectory, forKey: "subdirectory")
    }
}