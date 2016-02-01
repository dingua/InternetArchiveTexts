//
//  Chapter.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/28/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class Chapter: NSObject {
    var name: String?
    var zipFile: String!
    var scandata: String?
    
    init (zipFile: String) {
        self.zipFile = zipFile
        self.scandata = zipFile.substringToIndex((zipFile.rangeOfString("_jp2.zip")?.startIndex)!)+"_scandata.xml"
        self.name = zipFile.substringToIndex((zipFile.rangeOfString("_jp2.zip")?.startIndex)!)
    }
}