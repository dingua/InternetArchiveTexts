//
//  IABookmarkManager.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/15/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import Foundation

class IABookmarkManager {
    static let sharedInstance = IABookmarkManager()
    
    func triggerBookmark(page: IAPage) {
        if page.isBookmarked {
            removeBookmark(page)
        }else {
            addBookmark(page)
        }
    }
    
    private func addBookmark(page: IAPage) {
        let pageDB = Page.createPage(page, managedObjectContext: CoreDataStackManager.sharedManager.managedObjectContext)
        pageDB?.markBookmarked(true)
        CoreDataStackManager.sharedManager.saveContext()
        page.isBookmarked = true
    }

    private func removeBookmark(page: IAPage) {
        let pageDB = Page.createPage(page, managedObjectContext: CoreDataStackManager.sharedManager.managedObjectContext)
        pageDB?.markBookmarked(false)
        CoreDataStackManager.sharedManager.saveContext()
        page.isBookmarked = false
    }

}