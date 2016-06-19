 //
 //  IAItemsManager.swift
 //  Archive
 //
 //  Created by Mejdi Lassidi on 1/8/16.
 //  Copyright © 2016 Archive. All rights reserved.
 //
 
 import UIKit
 import Alamofire
 import SwiftyJSON
 
 enum IASearchSortOption: String {
    case DownloadsDescendant = "downloads+desc"
    case DownloadsAscendant = "downloads+asc"
    case TitleDescendant = "titleSorter+desc"
    case TitleAscendant = "titleSortekder+asc"
    case ArchivedDatedescendant = "addeddate+desc"
    case ArchivedDateAscendant = "addeddate+asc"
    case PublishedDatedescendant = "date+desc"
    case PublishedDateAscendant = "date+asc"
    case ReviewedDatedescendant = "reviewdate+desc"
    case ReviewedDateAscendant = "reviewdate+asc"
    case Relevance = ""
    
 }
 
 class IAItemsManager: NSObject {
    let baseURL = "https://archive.org"
    let searchURL = "advancedsearch.php?"
    var currentSearchRequest :Request?
    
    //MARK: - File Details
    
    func getFileDetails(archiveItem: IAArchiveItem, completion:(IAFile)->()){
        
        if let file = archiveItem.file {
            return completion(file)
        }else {
            let startDate = NSDate()
            let url = "\(baseURL)/metadata/\(archiveItem.identifier!)"
            Alamofire.request(Utils.requestWithURL(url))
                .responseJSON { response in
                    if let value = response.result.value {
                        completion(IAFile(dictionary: value as! [String : AnyObject], archiveItem: archiveItem))
                    }
            }
        }
    }
    
    //MARK: - Item Metadata
    
    func itemMetadata(identifier: String, item: ArchiveItem? = nil, completion:([String:AnyObject])->()) {
        let url = "\(baseURL)/metadata/\(identifier)"
        Alamofire.request(Utils.requestWithURL(url))
            .responseJSON { response in
                if let value = response.result.value {
                    let json = JSON(value)
                    if let item = item {
                        if item.file == nil {
                            item.setupFile(json.dictionaryObject!)
                        }
                    }
                    completion(json["metadata"].dictionaryObject!)
                }
        }
    }

    func itemMetadataDetails(identifier: String, completion:([String:AnyObject])->()) {
        let url = "\(baseURL)/metadata/\(identifier)/metadata"
        Alamofire.request(Utils.requestWithURL(url))
            .responseJSON { response in
                if let value = response.result.value {
                    let json = JSON(value)
                    if let result = json["result"].dictionaryObject {
                        completion(result)
                    } else {
                        completion([:])
                    }
                }
        }
    }

    
    func itemChapters(item: IAArchiveItem, completion:()->()) {
        let group = dispatch_group_create()
        let filesUrl = "\(baseURL)/metadata/\(item.identifier!)/files"
        
        dispatch_group_enter(group)
        var files: [AnyObject]?
        Alamofire.request(Utils.requestWithURL(filesUrl))
            .responseJSON { response in
                if let value = response.result.value {
                    let json = JSON(value)
                    if let filesArray = json["result"].arrayObject {
                        files = filesArray
                    }
                }
                dispatch_group_leave(group)

        }
        
        let serverUrl = "\(baseURL)/metadata/\(item.identifier!)/server"
        var server: String?
        dispatch_group_enter(group)
        Alamofire.request(Utils.requestWithURL(serverUrl))
            .responseJSON { response in
                if let value = response.result.value {
                    let json = JSON(value)
                    server = json["result"].stringValue
                }
                dispatch_group_leave(group)
                
        }
        let dirUrl = "\(baseURL)/metadata/\(item.identifier!)/dir"
        var dir: String?
        dispatch_group_enter(group)
        Alamofire.request(Utils.requestWithURL(dirUrl))
            .responseJSON { response in
                if let value = response.result.value {
                    let json = JSON(value)
                    dir = json["result"].stringValue
                }
                dispatch_group_leave(group)
                
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            if let files = files, server =  server, dir =  dir {
                item.file = IAFile(dictionary: ["server":server,"dir":dir,"files":files], archiveItem: item)
            }
            completion()
        }
    }

    //MARK: - Generic Search
    
    func searchItems(query: String, count: Int ,page: Int ,sort: String,completion: ([IAArchiveItem])->()) {
        if let currentSearchRequest = currentSearchRequest {
            currentSearchRequest.cancel()
        }
        let searchParameters = "q=(\(query))&sort%5B%5D=\(sort)&rows=\(count)&start=0&page=\(page)&output=json"
        
        let params = "\(baseURL)/\(searchURL)\(searchParameters)"
        currentSearchRequest = Alamofire.request(Utils.requestWithURL(params))
            .responseJSON { response in
                if let result = response.result.value {
                    let json = JSON(result)
                    let docs = json["response"]["docs"].array
                    if let docs = docs {
                        var collections = [IAArchiveItem]()
                        for doc in docs {
                            collections.append(IAArchiveItem(dictionary: doc.dictionaryObject!))
                        }
                        completion(collections)
                    }
                }
        }
    }
    
    
    //MARK: - Search Books Items
    
    func searchBooksWithText(word: String, count: Int, page: Int,completion: ([IAArchiveItem])->()) {
        searchBooksWithText(word, count: count, page: page, sortOption: IASearchSortOption.DownloadsDescendant, completion: completion)
    }
    
    func searchBookOfCreator(creator: String, count: Int, page: Int,completion: ([IAArchiveItem])->()) {
        searchBookOfCreator(creator, count: count, page: page, sortOption: IASearchSortOption.DownloadsDescendant, completion: completion)
    }
    
    func searchBookOfCollection(collection: String, count: Int, page: Int,completion: ([IAArchiveItem])->()) {
        searchBookOfCollection(collection, count: count, page: page, sortOption: IASearchSortOption.DownloadsDescendant, completion: completion)
    }
    
    func searchBooksWithText(word: String, count: Int, page: Int, sortOption: IASearchSortOption, completion: ([IAArchiveItem])->()) {
        let text = word.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let searchText = text.allowdStringForURL()
        let query = "\(searchText)%20AND%20mediatype:texts"
        searchItems(query, count: count, page: page, sort:  sortOption.rawValue, completion: completion)
    }
    
    
    func searchBookOfCreator(creator: String, count: Int, page: Int, sortOption: IASearchSortOption, completion: ([IAArchiveItem])->()) {
        let text = creator.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let searchText = text.allowdStringForURL()
        let query = "creator:\(searchText)%20AND%20mediatype:texts"
        searchItems(query, count: count, page: page, sort: sortOption.rawValue, completion: completion)
    }
    
    
    
    func searchBookOfCollection(collection: String, count: Int, page: Int,sortOption: IASearchSortOption, completion: ([IAArchiveItem])->()) {
        let text = collection.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let searchText = text.allowdStringForURL()
        let query = "collection:\(searchText)%20AND%20mediatype:texts"
        searchItems(query, count: count, page: page, sort: IASearchSortOption.DownloadsDescendant.rawValue, completion: completion)
    }
    
    //MARK: - Search Books Collections
    
    func searchCollections(collection: String,hidden: Bool, count: Int, page: Int,completion: ([IAArchiveItem])->()) {
        let text = collection.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let searchText = text.allowdStringForURL()
        let query = "collection:\(searchText)%20AND%20mediatype:collection%20AND%20NOT%20hidden:\(hidden)"
        
        searchItems(query, count: count, page: page, sort: IASearchSortOption.DownloadsDescendant.rawValue, completion: completion)
        
    }
    
    //MARK: - Search Books Collections & Texts
    
    func searchCollectionsAndTexts(collection: String,hidden: Bool, count: Int, page: Int,completion: ([IAArchiveItem])->()) {
        searchCollectionsAndTexts(collection, hidden: hidden, count: count, page: page, sortOption: IASearchSortOption.DownloadsDescendant, completion: completion)
    }
    
    func searchCollectionsAndTexts(collection: String,hidden: Bool, count: Int, page: Int, sortOption: IASearchSortOption, completion: ([IAArchiveItem])->()) {
        let text = collection.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let searchText = text.allowdStringForURL()
        let query = "collection:\(searchText)%20AND%20(mediatype:collection%20OR%20mediatype:texts)%20AND%20NOT%20hidden:\(hidden)"
        
        searchItems(query, count: count, page: page, sort: sortOption.rawValue, completion: completion)
    }
    
    func searchCollectionsAndTexts(uploader uploader: String,hidden: Bool, count: Int, page: Int, sortOption: IASearchSortOption, completion: ([IAArchiveItem])->()) {
        let text = uploader.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let searchText = text.allowdStringForURL()
        let query = "uploader:\(searchText)%20AND%20(mediatype:collection%20OR%20mediatype:texts)%20AND%20NOT%20hidden:\(hidden)"
        
        searchItems(query, count: count, page: page, sort: sortOption.rawValue, completion: completion)
    }
    
    func searchCollectionsAndTexts(subject subject: String,hidden: Bool, count: Int, page: Int, sortOption: IASearchSortOption, completion: ([IAArchiveItem])->()) {
        let text = subject.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let searchText = text.allowdStringForURL()
        let query = "subject:\(searchText)%20AND%20(mediatype:collection%20OR%20mediatype:texts)%20AND%20NOT%20hidden:\(hidden)"
        
        searchItems(query, count: count, page: page, sort: sortOption.rawValue, completion: completion)
    }
}
