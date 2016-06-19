//
//  IAChapter.swift
//  Archive
//
//  Created by Mejdi Lassidi on 6/14/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IAChapter {
    var name: String?
    var zipFile: String?
    var subdirectory: String?
    var numberOfPages: Int = 0
    var file: IAFile?
    var scandata: String?
    var type: Type?
    var pages: [IAPage]?
    
    init(zipFile: String, type: String, file: IAFile) {
        self.zipFile = zipFile
        if type == "JP2" {
            self.type = .JP2
        }else if type == "JPEG" {
            self.type = .JPG
        }else if type == "TIFF" {
            self.type = .TIF
        }else if type == "PDF" {
            self.type = .PDF
        }else if type == "JP2 Tar" {
            self.type = .JP2TAR
        }
        let fileExtension = (self.type == .JP2TAR) ? "tar" : "zip"
        self.scandata = (zipFile.substringToIndex((zipFile.rangeOfString("_\((self.type?.rawValue.lowercaseString)!).\(fileExtension)")?.startIndex)!)+"_scandata.xml")
        self.name = zipFile.substringToIndex((zipFile.rangeOfString("\((self.type?.rawValue.lowercaseString)!).\(fileExtension)")?.startIndex)!)
        self.subdirectory = zipFile.substringToIndex((zipFile.rangeOfString("_\((self.type?.rawValue.lowercaseString)!).\(fileExtension)")?.startIndex)!)
        self.file = file
    }
    
    init(chapter: Chapter) {
        self.zipFile = chapter.zipFile
        self.type = chapter.type
        self.scandata = chapter.scandata
        self.name = chapter.name
        self.subdirectory = chapter.subdirectory
        self.file =  IAFile(file: chapter.file!)
    }

}
