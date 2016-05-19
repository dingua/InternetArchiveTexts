//
//  IAFavouriteManager.swift
//  Archive
//
//  Created by Mejdi Lassidi on 4/28/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

private let bookmarkAPI = "https://archive.org/bookmarks.php?"
private let getBookmarkURL = "https://archive.org/bookmarks"

class IAFavouriteManager: NSObject {
    static let sharedInstance = IAFavouriteManager()
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(IAFavouriteManager.deleteAllBookmarks),
                                                         name: Constants.Notification.UserDidLogout.name,
                                                         object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func triggerBookmark(item: ArchiveItem, completion: ArchiveItem -> ()) {
        if item.isFavorite {
            deleteBookmark(item, completion: completion)
        }else {
            addBookmark(item, completion: completion)
        }
    }
    
    func addBookmark(item: ArchiveItem, completion: ArchiveItem -> ()) {
        let encodedTitle = item.title!.allowdStringForURL()
        let bookmarkURL = "\(bookmarkAPI)add_bookmark=1&mediatype=texts&identifier=\(item.identifier!)&title=\(encodedTitle)&output=json"
        Alamofire.request(.GET, bookmarkURL).responseJSON (completionHandler: { response in
            if let _ = response.result.value {
                self.addBookmark(item)
                completion(item)
            }
        })
    }
    
    func deleteBookmark(item: ArchiveItem, completion: ArchiveItem -> ()) {
        let bookmarkURL = "\(bookmarkAPI)del_bookmark=\(item.identifier!)"
        Alamofire.request(.GET, bookmarkURL).responseString(completionHandler: { response in
            self.deleteBookmark(item)
            completion(item)
            
        })
    }
    
    private func addBookmark(item: ArchiveItem) {
       item.markAsFavourite(true)
    }
    
    
    private func deleteBookmark(item: ArchiveItem) {
        item.markAsFavourite(false)
    }
    
    func getBookmarks(userId: String, completion: () -> ()) {
        let url = "\(getBookmarkURL)/\(userId)?output=json"
        
        Alamofire.request(Utils.requestWithURL(url)).responseJSON { response in
            if let result = response.result.value {
                let bookmarks = JSON(result).arrayValue
                for bookmark in bookmarks {
                    if bookmark["mediatype"].stringValue == "texts" {
                        if let bookItem = ArchiveItem.createArchiveItem(bookmark.dictionaryObject!, managedObjectContext: CoreDataStackManager.sharedManager.managedObjectContext, temporary: false){
                            bookItem.markAsFavourite(true)
                        }
                    }
                }
            }
            
            completion()
        }
    }
    
    func deleteAllBookmarks() {
        ArchiveItem.deleteAllFavourites()
    }
}
