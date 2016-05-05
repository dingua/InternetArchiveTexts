//
//  IABookmarkManager.swift
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

class IABookmarkManager: NSObject {
    static let sharedInstance = IABookmarkManager()
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IABookmarkManager.deleteAllBookmarks), name: notificationUserDidLogout, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, forKeyPath: notificationUserDidLogout)
    }
 
    func addBookmark(item: ArchiveItemData, completion: String -> ()) {
        let encodedTitle = item.title!.allowdStringForURL()
        let bookmarkURL = "\(bookmarkAPI)add_bookmark=1&mediatype=texts&identifier=\(item.identifier!)&title=\(encodedTitle)&output=json"
        Alamofire.request(.GET, bookmarkURL).responseJSON (completionHandler: { response in
            if let value = response.result.value {
                self.addBookmark(item)
                let json = JSON(value)
                    completion(json["msg"].stringValue)
            }
        })
    }
    
    func deleteBookmark(identifier: String, completion: String -> ()) {
        let bookmarkURL = "\(bookmarkAPI)del_bookmark=\(identifier)"
        Alamofire.request(.GET, bookmarkURL).responseString(completionHandler: { response in
            self.deleteBookmark(identifier)
            completion(identifier)
            
        })
    }
    
    private func addBookmark(item: ArchiveItemData) {
        ArchiveItem.createArchiveItemWithData(item, isFavourite: true)
    }
    
    
    private func deleteBookmark(identifier: String) {
        ArchiveItem.deleteItem(identifier)
    }

    func getBookmarks(userId: String, completion: (NSArray)->()) {
        let url = "\(getBookmarkURL)/\(userId)?output=json"
        Alamofire.request(Utils.requestWithURL(url))
            .responseJSON { response in
                if let JSON = response.result.value {
                        let collections = NSMutableArray()
                        for index in 0 ..< JSON.count {
                            let dictionary = ((JSON as! Array)[index]) as NSDictionary
                            if let mediatype = dictionary.valueForKey("mediatype") as? String{
                                if mediatype == "texts" {
                                    let item = ArchiveItemData(dictionary: dictionary )
                                    ArchiveItem.createArchiveItemWithData(item, isFavourite: true)
                                }
                            }
                        }
                        completion(collections)
                    }
                }
    }
    
    func deleteAllBookmarks() {
        ArchiveItem.deleteAllFavourites()
    }
}
