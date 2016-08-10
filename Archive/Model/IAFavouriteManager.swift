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
    
    func triggerFavorite(item: IAArchiveItem, completion: IAArchiveItem -> ()) {
        if item.isFavourite {
            deleteBookmark(item, completion: completion)
        }else {
            addBookmark(item, completion: completion)
        }
    }
    
    func addBookmark(item: IAArchiveItem, completion: IAArchiveItem -> ()) {
        let encodedTitle = item.title!.allowdStringForURL()
        let bookmarkURL = "\(bookmarkAPI)add_bookmark=1&mediatype=texts&identifier=\(item.identifier!)&title=\(encodedTitle)&output=json"
        Alamofire.request(.GET, bookmarkURL).responseJSON (completionHandler: { response in
            if let _ = response.result.value {
                self.addBookmark(item)
                completion(item)
            }
        })
    }
    
    func deleteBookmark(item: IAArchiveItem, completion: IAArchiveItem -> ()) {
        let bookmarkURL = "\(bookmarkAPI)del_bookmark=\(item.identifier!)"
        Alamofire.request(.GET, bookmarkURL).responseString(completionHandler: { response in
            self.deleteBookmark(item)
            completion(item)
        })
    }
    
    private func addBookmark(item: IAArchiveItem) {
        item.isFavourite = true
        let managedObjectContext = CoreDataStackManager.sharedManager.managedObjectContext
        let archiveItem = ArchiveItem.createArchiveItem(item, managedObjectContext: managedObjectContext)
        archiveItem?.markAsFavourite(true)
        CoreDataStackManager.sharedManager.saveContext()
    }
    
    private func deleteBookmark(item: IAArchiveItem) {
        item.isFavourite = false
        let managedObjectContext = CoreDataStackManager.sharedManager.managedObjectContext
        let archiveItem = ArchiveItem.createArchiveItem(item, managedObjectContext: managedObjectContext)
        archiveItem?.markAsFavourite(false)
        CoreDataStackManager.sharedManager.saveContext()
    }
    
    func getBookmarks(userId: String, completion: () -> ()) {
        let url = "\(getBookmarkURL)/\(userId)?output=json"
        
        Alamofire.request(Utils.requestWithURL(url)).responseJSON { response in
            do {
                let group = dispatch_group_create()
                let managedObjectContext = try CoreDataStackManager.sharedManager.createPrivateQueueContext()
                if let result = response.result.value {
                    let bookmarks = JSON(result).arrayValue
                    for bookmark in bookmarks {
                        if bookmark["mediatype"].stringValue == "texts" {
                            dispatch_group_enter(group)
                            managedObjectContext.performBlock {
                                if let bookItem = ArchiveItem.createArchiveItem(bookmark.dictionaryObject!, save: false){
                                    bookItem.markAsFavourite(true)
                                }
                                dispatch_group_leave(group)
                            }
                        }
                    }
                }
                dispatch_group_notify(group, dispatch_get_main_queue(), {
                    CoreDataStackManager.sharedManager.saveContext()
                    completion()
                })

            }catch {
                completion()
            }
        }
    }
    
    func deleteAllBookmarks() {
        ArchiveItem.deleteAllFavourites()
    }
}
