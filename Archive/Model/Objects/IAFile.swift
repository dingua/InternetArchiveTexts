//
//  IAFile.swift
//  Archive
//
//  Created by Mejdi Lassidi on 6/14/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import SwiftyJSON

class IAFile {
    var server: String?
    var directory: String?
    var chapters = [IAChapter]()
    var archiveItem: IAArchiveItem?
    
    init(dictionary: [String:AnyObject], archiveItem: IAArchiveItem) {
        let json = JSON(dictionary)
        self.server = json["server"].stringValue
        self.directory = json["dir"].stringValue
        self.archiveItem = archiveItem

        let docs = json["files"].arrayValue
        for doc in docs {
            let format = doc["format"].stringValue
            if format.containsString("Single Page Processed") {
                var type = format.substringFromIndex((format.rangeOfString("Single Page Processed ")?.endIndex)!)
                if type.containsString(" ZIP") {
                    type = type.substringToIndex((type.rangeOfString(" ZIP")?.startIndex)!)
                }
                let chapter = IAChapter(zipFile: doc["name"].stringValue,type: type, file: self)
                self.chapters.append(chapter)
            }
        }
    }

    init(file: File) {
        self.server = file.server
        self.directory = file.directory
        self.archiveItem = IAArchiveItem(item: file.archiveItem!)
    }
}
