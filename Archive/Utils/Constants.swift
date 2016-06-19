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
        case ImageURLForPage(IAPage,withScale: Int)
        case ScandataURL(IAChapter)
        case ScandataURLZipPreview(IAChapter)
        case ZipFileURL(IAChapter)
        var url: NSURL {
            var path = ""
            
            switch self {
            case .ImageURL(let identifier):
                path = URL.BaseURL + "/services/img/" + identifier
                
            case .ImageURLForPage(let page, let scale):
                path = page.urlOfPage(scale)
            case .ScandataURL(let chapter):
                path = "https://\(chapter.file!.server!)\(chapter.file!.directory!)/\(chapter.scandata!)".allowdStringForURL()
            case .ScandataURLZipPreview(let chapter):
                path = "https://\(chapter.file!.server!)/zipview.php?zip=\(chapter.file!.directory!)/scandata.zip&file=scandata.xml".allowdStringForURL()
            case .ZipFileURL(let chapter):
                let type = chapter.type?.rawValue.lowercaseString
                path = "https://\(chapter.file!.server!)\(chapter.file!.directory!)/\(chapter.subdirectory!)_\(type!).zip".allowdStringForURL()
            
            }
            
            return NSURL(string: path)!
        }

        var urlString: String {
            return url.absoluteString
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
