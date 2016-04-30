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

class IABookmarkManager {

    class func addBookmark(bookId: String, title: String, completion: String -> ()) {
        let encodedTitle = title.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let bookmarkURL = "https://archive.org/bookmarks.php?add_bookmark=1&mediatype=texts&identifier=\(bookId)&title=\(encodedTitle)&output=json"
        Alamofire.request(.GET, bookmarkURL).responseJSON (completionHandler: { response in
            if let value = response.result.value {
                addBookmark(bookId)
                let json = JSON(value)
                    completion(json["msg"].stringValue)
            }
        })
    }
    
    class func deleteBookmark(bookId: String, completion: String -> ()) {
        let bookmarkURL = "https://archive.org/bookmarks.php?del_bookmark=\(bookId)"
        Alamofire.request(.GET, bookmarkURL).responseString(completionHandler: { response in
            deleteBookmark(bookId)
            completion(bookId)
            
        })
    }
    
    class func addBookmark(identifier : String) {
        if let favouriteList = NSUserDefaults.standardUserDefaults().objectForKey(favouriteListIds) as? [String] {
            var newFavouriteList = favouriteList
            if !favouriteList.contains(identifier) {
                newFavouriteList.append(identifier)
            }
            NSUserDefaults.standardUserDefaults().setObject(newFavouriteList, forKey: favouriteListIds)
            NSNotificationCenter.defaultCenter().postNotificationName(notificationBookmarkAdded, object: nil)
        }else {
            NSUserDefaults.standardUserDefaults().setObject([identifier], forKey: favouriteListIds)
            NSNotificationCenter.defaultCenter().postNotificationName(notificationBookmarkAdded, object: nil)
        }
    }
    
    
    class func deleteBookmark(identifier : String) {
        if let favouriteList = NSUserDefaults.standardUserDefaults().objectForKey(favouriteListIds) as? [String] {
            var newFavouriteList = favouriteList
            if favouriteList.contains(identifier) {
                newFavouriteList.removeObject(identifier)
            }
            NSUserDefaults.standardUserDefaults().setObject(newFavouriteList, forKey: favouriteListIds)
            NSNotificationCenter.defaultCenter().postNotificationName(notificationBookmarkRemoved, object: nil)
        }
    }

    class func getBookmarks(userId: String, completion: (NSArray)->()) {
        let url = "https://archive.org/bookmarks/\(userId)?output=json"
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                if let JSON = response.result.value {
                        let collections = NSMutableArray()
                        for index in 0 ..< JSON.count {
                            let dictionary = ((JSON as! Array)[index]) as NSDictionary
                            if let mediatype = dictionary.valueForKey("mediatype") as? String{
                                if mediatype == "texts" {
                                    collections.addObject(ArchiveItemData(dictionary: dictionary ))
                                }
                            }
                        }
                        synchronizeFavourites(collections)
                        completion(collections)
                    }
                }
        }
    
    class func synchronizeFavourites(items: NSMutableArray) {
            var favouriteList = [] as [String]!
            for item  in items {
                favouriteList.append(item.identifier!)
            }
            NSUserDefaults.standardUserDefaults().setObject(favouriteList, forKey: favouriteListIds)
            NSUserDefaults.standardUserDefaults().synchronize()
    }

}
