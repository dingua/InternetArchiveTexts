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

class Chapter: NSObject {
    var name: String?
    var zipFile: String!
    var scandata: String?
    var type: FileType?

    init (zipFile: String) {
        self.zipFile = zipFile
        self.scandata = zipFile.substringToIndex((zipFile.rangeOfString("_jp2.zip")?.startIndex)!)+"_scandata.xml"
        self.name = zipFile.substringToIndex((zipFile.rangeOfString("_jp2.zip")?.startIndex)!)
    }
    init (zipFile: String, type: String) {
        self.zipFile = zipFile
         if type == "JP2" {
            self.type = .JP2
        }else if type == "TIFF" {
            self.type = .TIFF
        }else if type == "PDF" {
            self.type = .PDF
        }
        self.scandata = zipFile.substringToIndex((zipFile.rangeOfString("_\((self.type?.rawValue.lowercaseString)!).zip")?.startIndex)!)+"_scandata.xml"
        self.name = zipFile.substringToIndex((zipFile.rangeOfString("\((self.type?.rawValue.lowercaseString)!).zip")?.startIndex)!)
        
        
    }

}