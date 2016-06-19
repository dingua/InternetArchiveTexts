//
//  IAPage.swift
//  Archive
//
//  Created by Mejdi Lassidi on 6/14/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IAPage: NSObject {
    var number: Int?
    var isBookmarked: Bool = false
    var chapter: IAChapter?
    
    init(number: String, chapter: IAChapter, isBookmarked: Bool) {
        self.number = Int(number)
        self.isBookmarked = isBookmarked
        self.chapter = chapter
    }
    
    init(page: Page) {
        self.number = page.number?.integerValue
        self.isBookmarked = page.isBookmarked?.boolValue ?? false
        self.chapter = IAChapter(chapter: page.chapter!)
    }
    
    func urlOfPage(scale: Int) -> String{
        let type = self.chapter!.type!.rawValue.lowercaseString
        return "https://\(self.chapter!.file!.server!)\(readerMethod)zip=\(self.chapter!.file!.directory!)/\(self.chapter!.subdirectory!)_\(type).zip&file=\(self.chapter!.subdirectory!)_\(type)/\(self.chapter!.subdirectory!)_\(String(format: "%04d", self.number!)).\(type)&scale=\(scale)".allowdStringForURL()
    }
}
