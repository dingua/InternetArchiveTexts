//
//  Constants.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/24/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import Foundation
let imageBaseURL = "https://archive.org/services/img/"
let notificationUserDidLogout = "userDidlogout"
let notificationUserDidLogin = "userLoggedIn"
let favouriteListIds = "favouriteIds"
let notificationBookmarkAdded = "bookMarkAdded"
let notificationBookmarkRemoved = "bookMarkRemoved"
let notificationDownloadedAdded = "donloadAdded"

struct Constants {
    
    struct URL {
        static let BaseURL = "https://archive.org"
        static let ImageURL = BaseURL + "/services/img/"
    }
    
    static func ImageURL(identifier: String) -> NSURL {
        let urlString = URL.ImageURL + identifier
        return NSURL(string: urlString)!
    }
    
    struct Notification {
        static let UserDidLogIn  = "UserDidLogInNotification"
        static let UserDidLogOut = "UserDidLogOutNotification"
    }
    
}
