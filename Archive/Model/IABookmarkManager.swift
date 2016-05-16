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
    
    func triggerBookmark(page: Page) {
        if page.bookmarked {
            removeBookmark(page)
        }else {
            addBookmark(page)
        }
    }
    
    private func addBookmark(page: Page) {
        page.markBookmarked(true)
    }

    private func removeBookmark(page: Page) {
        page.markBookmarked(false)
    }

}