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
    case TitleAscendant = "titleSorter+asc"
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
    
    func getFileDetails(archiveItem: ArchiveItem, completion:(File)->()){
        
        if let file = archiveItem.file {
            return completion(file)
        }else {
            let startDate = NSDate()
            let url = "\(baseURL)/metadata/\(archiveItem.identifier!)"
            Alamofire.request(Utils.requestWithURL(url))
                .responseJSON { response in
                    if let value = response.result.value {
                        if let managedObjectContext = archiveItem.managedObjectContext {
                            if let file = File.createFile(value as! [String : AnyObject], archiveItem: archiveItem, managedObjectContext: managedObjectContext, temporary: false) {
                                completion(file)
                            }
                        }else {
                            do{
                                let managedObjectContext = try CoreDataStackManager.sharedManager.createPrivateQueueContext()
                                if let file = File.createFile(value as! [String : AnyObject], archiveItem: archiveItem, managedObjectContext: managedObjectContext, temporary: !(archiveItem.isFavourite!.boolValue)) {
                                    completion(file)
                                    managedObjectContext.reset()
                                }
                            }catch let error as NSError{
                                print("could not create managed object context \(error.localizedDescription)")
                            }
                        }
                        print("get file details finished in \(NSDate().timeIntervalSinceDate(startDate))")
                    }
            }
        }
    }
    
    //MARK: - Generic Search
    
    func searchItems(query: String, count: Int ,page: Int ,sort: String,completion: ([ArchiveItem])->()) {
        if let currentSearchRequest = currentSearchRequest {
            currentSearchRequest.cancel()
        }
        let searchParameters = "q=(\(query))&sort%5B%5D=\(sort)&rows=\(count)&start=0&page=\(page)&output=json"
        
        let params = "\(baseURL)/\(searchURL)\(searchParameters)"
        currentSearchRequest = Alamofire.request(Utils.requestWithURL(params))
            .responseJSON { response in
                do{
                    let managedObjectContext = try CoreDataStackManager.sharedManager.createPrivateQueueContext()
                    if let result = response.result.value {
                        let json = JSON(result)
                        let docs = json["response"]["docs"].array
                        if let docs = docs {
                            var collections = [ArchiveItem]()
                            for doc in docs {
                                collections.append(ArchiveItem.createArchiveItem(doc.dictionaryObject!, managedObjectContext: managedObjectContext, temporary: true)!)
                            }
                            completion(collections)
                            managedObjectContext.reset()
                        }
                    }
                }catch{
                    print("Error: \(error)\nCould not get managed Object Context.")
                    return
                    
                }
        }
    }
    
    
    //MARK: - Search Books Items
    
    func searchBooksWithText(word: String, count: Int, page: Int,completion: ([ArchiveItem])->()) {
        searchBooksWithText(word, count: count, page: page, sortOption: IASearchSortOption.DownloadsDescendant, completion: completion)
    }
    
    func searchBookOfCreator(creator: String, count: Int, page: Int,completion: ([ArchiveItem])->()) {
        searchBookOfCreator(creator, count: count, page: page, sortOption: IASearchSortOption.DownloadsDescendant, completion: completion)
    }
    
    func searchBookOfCollection(collection: String, count: Int, page: Int,completion: ([ArchiveItem])->()) {
        searchBookOfCollection(collection, count: count, page: page, sortOption: IASearchSortOption.DownloadsDescendant, completion: completion)
    }
    
    func searchBooksWithText(word: String, count: Int, page: Int, sortOption: IASearchSortOption, completion: ([ArchiveItem])->()) {
        let text = word.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let searchText = text.allowdStringForURL()
        let query = "\(searchText)%20AND%20mediatype:texts"
        searchItems(query, count: count, page: page, sort:  sortOption.rawValue, completion: completion)
    }
    
    
    func searchBookOfCreator(creator: String, count: Int, page: Int, sortOption: IASearchSortOption, completion: ([ArchiveItem])->()) {
        let text = creator.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let searchText = text.allowdStringForURL()
        let query = "creator:\(searchText)%20AND%20mediatype:texts"
        searchItems(query, count: count, page: page, sort: sortOption.rawValue, completion: completion)
    }
    
    
    
    func searchBookOfCollection(collection: String, count: Int, page: Int,sortOption: IASearchSortOption, completion: ([ArchiveItem])->()) {
        let text = collection.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let searchText = text.allowdStringForURL()
        let query = "collection:\(searchText)%20AND%20mediatype:texts"
        searchItems(query, count: count, page: page, sort: IASearchSortOption.DownloadsDescendant.rawValue, completion: completion)
    }
    
    //MARK: - Search Books Collections
    
    func searchCollections(collection: String,hidden: Bool, count: Int, page: Int,completion: ([ArchiveItem])->()) {
        let text = collection.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let searchText = text.allowdStringForURL()
        let query = "collection:\(searchText)%20AND%20mediatype:collection%20AND%20NOT%20hidden:\(hidden)"
        
        searchItems(query, count: count, page: page, sort: IASearchSortOption.DownloadsDescendant.rawValue, completion: completion)
        
    }
    
    //MARK: - Search Books Collections & Texts
    
    func searchCollectionsAndTexts(collection: String,hidden: Bool, count: Int, page: Int,completion: ([ArchiveItem])->()) {
        searchCollectionsAndTexts(collection, hidden: hidden, count: count, page: page, sortOption: IASearchSortOption.DownloadsDescendant, completion: completion)
    }
    
    func searchCollectionsAndTexts(collection: String,hidden: Bool, count: Int, page: Int, sortOption: IASearchSortOption, completion: ([ArchiveItem])->()) {
        let text = collection.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let query = "collection:\(text)%20AND%20(mediatype:collection%20OR%20mediatype:texts)%20AND%20NOT%20hidden:\(hidden)"
        
        searchItems(query, count: count, page: page, sort: sortOption.rawValue, completion: completion)
    }
}
