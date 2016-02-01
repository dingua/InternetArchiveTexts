//
//  File.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/9/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class File: NSObject {
    var identifier: String!
    var server: String?
    var directory: String?
    var subdirectory: String?
    var uploader: String?
    var collection: String?
    var scandata: String?
    var chapters: [Chapter]?
    
    init(identifier: String) {
        self.identifier = identifier
    }
}
