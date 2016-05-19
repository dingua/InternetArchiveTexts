//
//  Constants.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/24/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import Foundation

struct Constants {
    
    enum Keys: String {
        case UserID = "userid"
        case FavoriteListIDs = "favouriteIds"
        case Secret = "secretkey"
        case Access = "accesskey"
    }
    
    enum URL {
        static let BaseURL = "https://archive.org"
        
        case ImageURL(String)
        case ImageURLForPage(Page,withScale: Int)
        
        var url: NSURL {
            var path = ""
            
            switch self {
            case .ImageURL(let identifier):
                path = URL.BaseURL + "/services/img/" + identifier
                
            case .ImageURLForPage(let page, let scale):
                path = page.urlOfPage(scale)
            }
            
            return NSURL(string: path)!
        }
    }
    
    enum Notification: String {
        case UserDidLogin
        case UserDidLogout
        case BookmarkDidAdd
        case BookmarkDidRemove
        case DownloadDidAdd
        
        var name: String {
            return self.rawValue + "Notification"
        }
    }
    
}
