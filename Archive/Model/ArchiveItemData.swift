//
//  ArchiveItemData.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/18/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import Foundation

class ArchiveItemData :  NSObject {
    var identifier: String?
    var publicdate: NSDate?
    var publisher: String?
    var creator: String?
    var title: String?
    var desc: String?
    var mediatype: String?
    var formats: NSSet?
    var collections : NSArray?
    var subjects : NSArray?
    
    init(dictionary: NSDictionary) {
        identifier = dictionary.valueForKey("identifier") as? String
        desc = dictionary.valueForKey("description") as? String
        title = dictionary.valueForKey("title") as? String
        creator = dictionary.valueForKeyPath("creator") as? String
        mediatype = dictionary.valueForKeyPath("mediatype") as? String
        publisher = dictionary.valueForKeyPath("publisher") as? String

        if let collections = dictionary.valueForKeyPath("collection") as? NSArray {
            self.collections = collections
        }
        if let subjects = dictionary.valueForKeyPath("subject") as? NSArray {
            self.subjects = subjects
        }else if let subject = dictionary.valueForKeyPath("subject") as? NSString {
            self.subjects = NSArray(object: subject)
        }
    }
    
    func isFavourite()->Bool {
        if let favouriteList = NSUserDefaults.standardUserDefaults().objectForKey(favouriteListIds) as? [String] {
            if !favouriteList.contains(self.identifier!) {
                return false
            }else {
                return true
            }
            
        }else {
            return false
        }
    }
}