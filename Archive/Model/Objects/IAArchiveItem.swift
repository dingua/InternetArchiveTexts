//
//  IAArchiveItem.swift
//  Archive
//
//  Created by Mejdi Lassidi on 6/14/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IAArchiveItem {
    var desc: String?
    var identifier: String?
    var publicdate: NSDate?
    var publisher: String?
    var mediatype: String?
    var title: String?
    var isFavourite = false
    var file: IAFile?
    var collections = [IAArchiveItem]()
    var uploader: String?
    var subjects = [String]()
    var authors = [String]()
    init(dictionary:[String:AnyObject]) {
        if let identifier = dictionary["identifier"] as? String {
            self.identifier = identifier
            self.isFavourite = ArchiveItem.isFavourite(identifier)
        }
        if let description = dictionary["description"] as? String {
            self.desc = description
        }
        if let title = dictionary["title"] as? String {
            self.title = title
        }
        if let mediatype = dictionary["mediatype"] as? String {
            self.mediatype = mediatype
        }
        if let uploader = dictionary["uploader"] as? String {
            self.uploader = uploader
        }
        if let subjects = dictionary["subject"] as? [String] {
            self.subjects = subjects
        }else if let subject = dictionary["subject"] as? String {
            subjects.append(subject)
        }
        if let authors = dictionary["creator"] as? [String] {
            self.authors = authors
        }else if let author = dictionary["creator"] as? String {
            authors.append(author)
        }
    }
    
    init(item: ArchiveItem) {
            self.identifier = item.identifier
            self.isFavourite = item.isFavorite
            self.desc = item.desc
            self.title = item.title
            self.mediatype = item.mediatype
            self.uploader = item.uploader
        if let subjects = item.subjects {
            for subject in subjects.allObjects as! [Subject] {
                self.subjects.append(subject.name!)
            }
        }
        if let authors = item.authors {
            for author in authors.allObjects as! [Author] {
                self.authors.append(author.name!)
            }
        }
    }
    
    func updateDetails(dictionary:[String:AnyObject]) {
    }
}
