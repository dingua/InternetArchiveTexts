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
 }
 
 class IAItemsManager: NSObject {
    let baseURL = "https://archive.org"
    let searchURL = "advancedsearch.php?"
    
    //MARK: - File Details
    
    func getFileDetails(identifier: String, completion:(File)->()){
        Alamofire.request(.GET, "\(baseURL)/metadata/\(identifier)", parameters: nil)
            .responseJSON { response in
                if let value = response.result.value {
                    let json = JSON(value)
                    let server = json["server"].stringValue
                    let directory = json["dir"].stringValue
                    
                    let docs = json["files"].arrayValue
                    var chapters : [Chapter] = []
                    for doc in docs {
                        let format = doc["format"].stringValue
                        if format.containsString("Single Page Processed") {
                            var type = format.substringFromIndex((format.rangeOfString("Single Page Processed ")?.endIndex)!)
                            if type.containsString(" ZIP") {
                                type = type.substringToIndex((type.rangeOfString(" ZIP")?.startIndex)!)
                            }
                            chapters.append(Chapter(zipFile: doc["name"].stringValue,type: type))
                        }
                    }
                    chapters.sortInPlace({$0.name < $1.name })
                    
                    if chapters.count == 0 {
                        completion(File(identifier: ""))
                        return
                    }
                    
                    let file = File(identifier: identifier)
                    file.server = server
                    file.directory = directory
                    file.chapters = chapters
                    completion(file)
                }
        }
    }
    
    //MARK: - Generic Search
    
    func searchItems(query: String, count: Int, offset: Int, sort: String,completion: (NSArray)->()) {
        let searchParameters = "q=(\(query))&sort%5B%5D=\(sort)&rows=\(count)&output=json&start=\(offset)"
        
        let params = "\(baseURL)/\(searchURL)\(searchParameters)"
        Alamofire.request(.GET, params, parameters: nil)
            .responseJSON { response in
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                    if let response = JSON.valueForKey("response")  {
                        let docs = response.valueForKey("docs") as! NSArray
                        let collections = NSMutableArray()
                        for var index = 0;index < docs.count;++index {
                            collections.addObject(ArchiveItemData(dictionary: docs[index] as! NSDictionary))
                        }
                        completion(collections)
                    }
                }
        }
    }

    
    //MARK: - Search Books Items
    
    func searchBooksWithText(word: String, count: Int, offset: Int,completion: (NSArray)->()) {
       searchBooksWithText(word, count: count, offset: offset, sortOption: IASearchSortOption.DownloadsDescendant, completion: completion)
    }
   
    func searchBookOfCreator(creator: String, count: Int, offset: Int,completion: (NSArray)->()) {
        searchBookOfCreator(creator, count: count, offset: offset, sortOption: IASearchSortOption.DownloadsDescendant, completion: completion)
    }

    func searchBookOfCollection(collection: String, count: Int, offset: Int,completion: (NSArray)->()) {
        searchBookOfCollection(collection, count: count, offset: offset, sortOption: IASearchSortOption.DownloadsDescendant, completion: completion)
    }
    
    func searchBooksWithText(word: String, count: Int, offset: Int, sortOption: IASearchSortOption, completion: (NSArray)->()) {
        let text = word.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let query = "title:\(text)%20OR%20description:\(text)%20OR%20collection:\(text)%20OR%20language:\(text)%20OR%20text:\(text)%20AND%20mediatype:texts"
        searchItems(query, count: count, offset: offset, sort:  sortOption.rawValue, completion: completion)
    }
    
   
    func searchBookOfCreator(creator: String, count: Int, offset: Int, sortOption: IASearchSortOption, completion: (NSArray)->()) {
        let text = creator.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let query = "creator:\(text)%20AND%20mediatype:texts"
        searchItems(query, count: count, offset: offset, sort: sortOption.rawValue, completion: completion)
    }

    
    
    func searchBookOfCollection(collection: String, count: Int, offset: Int,sortOption: IASearchSortOption, completion: (NSArray)->()) {
        let text = collection.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let query = "collection:\(text)%20AND%20mediatype:texts"
        searchItems(query, count: count, offset: offset, sort: IASearchSortOption.DownloadsDescendant.rawValue, completion: completion)
    }
    
    //MARK: - Search Books Collections
    
    func searchCollections(collection: String,hidden: Bool, count: Int, offset: Int,completion: (NSArray)->()) {
        let text = collection.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let query = "collection:\(text)%20AND%20mediatype:collection%20AND%20NOT%20hidden:\(hidden)"
        
        searchItems(query, count: count, offset: offset, sort: IASearchSortOption.DownloadsDescendant.rawValue, completion: completion)
        
    }
    
    //MARK: - Search Books Collections & Texts
    
    func searchCollectionsAndTexts(collection: String,hidden: Bool, count: Int, offset: Int,completion: (NSArray)->()) {
        searchCollectionsAndTexts(collection, hidden: hidden, count: count, offset: offset, sortOption: IASearchSortOption.DownloadsDescendant, completion: completion)
    }

    func searchCollectionsAndTexts(collection: String,hidden: Bool, count: Int, offset: Int, sortOption: IASearchSortOption, completion: (NSArray)->()) {
        let text = collection.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let query = "collection:\(text)%20AND%20(mediatype:collection%20OR%20mediatype:texts)%20AND%20NOT%20hidden:\(hidden)"
        
        searchItems(query, count: count, offset: offset, sort: sortOption.rawValue, completion: completion)
    }

    //MARK: - Gather Subjects
    
    func getSubjectsOfCollection(collection: String,count: Int,page: Int,completion:(NSArray)->()){
        let searchMethod = searchURL
        let text = collection.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let searchParameters = "q=(collection:\(text)%20AND%20(mediatype:collection%20OR%20mediatype:texts))&fl%5B%5D=subject&sort%5B%5D=downloads+desc&rows=\(count)&output=json&start=0&page=\(page)"
        
        let params = "\(baseURL)/\(searchMethod)\(searchParameters)"
        Alamofire.request(.GET, params, parameters: nil)
            .responseJSON { response in
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                    if let response = JSON.valueForKey("response")  {
                        let docs = response.valueForKey("docs") as! NSArray
                        let collections = NSMutableArray()
                        for var index = 0;index < docs.count;++index {
                            collections.addObject(ArchiveItemData(dictionary: docs[index] as! NSDictionary))
                        }
                        completion(collections)
                    }
                }
        }
        
    }
    
    //MARK: - Get number of books
    
    func getNumberBookOfCollection(collection: String,completion:(Int)->()){
        let searchMethod = searchURL
        let text = collection.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let searchParameters = "q=(collection:\(text)%20AND%20(mediatype:collection%20OR%20mediatype:texts))&sort%5B%5D=downloads+desc&rows=0&output=json&start=0"
        
        let params = "\(baseURL)/\(searchMethod)\(searchParameters)"
        Alamofire.request(.GET, params, parameters: nil)
            .responseJSON { response in
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                    if let response = JSON.valueForKey("response")  {
                        if let numberFound = response.valueForKey("numFound") {
                            completion(numberFound as! Int)
                        }
                    }
                }
        }
    }
    
 }
