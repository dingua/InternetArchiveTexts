//
//  IABookImagesManager.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/8/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire
import TBXML
import SSZipArchive
import CoreData

extension Array where Element: Equatable {
    mutating func removeObject(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
    
    mutating func removeObjectsInArray(array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
}

let readerMethod = "/BookReader/BookReaderImages.php?"

class IABookImagesManager: NSObject {
    
    //MARK: - Properties
    
    var file: IAFile
    var chapterIndex: Int
    var chapter : IAChapter
    var type : String?
    
    let imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .FIFO,
        maximumActiveDownloads: 4,
        imageCache: AutoPurgingImageCache()
    )
    
    var requests : Array<Alamofire.Request>?
    var pages : [IAPage]?
    private var _numberOfPages : Int?
    var numberOfPages : Int? {
        get {
            return self._numberOfPages
        }
        set {
            self.chapter.numberOfPages = newValue!
            self._numberOfPages = newValue
        }
    }
    
    //MARK: - Initializer
    
    init(file : IAFile, chapterIndex : Int) {
        
        self.file = file
        self.chapterIndex = chapterIndex
        self.chapter = self.file.chapters.sort({$0.name < $1.name})[chapterIndex]
        self.type = self.chapter.type?.rawValue.lowercaseString
        self.requests = Array()
    }
    
    //MARK: - Download Pages
    
    func urlOfPage(number: Int) -> String{
        return urlOfPage(number,scale: 2)
    }
    
    func urlOfPage(number: Int, scale: Int) -> String{
        return Constants.URL.ImageURLForPage(pages![number], withScale: scale).urlString
    }
    
    func getImages(offset: Int, count:Int,updateImage:(index: Int, image: UIImage)->() , completion:()->()) {
        guard pages != nil && pages?.count>0 else{return}
        let group = dispatch_group_create();
        for index in offset...offset+count {
            dispatch_group_enter(group)
            if index<0 || self.numberOfPages!<=index{
                dispatch_group_leave(group)
            }else {
                if isChapterStored() {
                    updateImage(index: index, image: UIImage(data: NSData(contentsOfFile: "\(self.docuementsDirectory())/\(self.chapter.subdirectory!)_\(type!)/\(self.chapter.subdirectory!)_\(String(format: "%04d", index)).\(type!)")!)!)
                }else {
                    let requestReceipt =  self.downloadImageAtIndex(index, updateImage: updateImage)
                    if let requestReceipt = requestReceipt {
                        self.requests?.append(requestReceipt.request)
                    }
                }
            }
            
        }
        dispatch_group_notify(group, dispatch_get_main_queue()) { () -> Void in
            completion()
        }
    }
    
    func imageOfPage(number: Int,completion:(page: Int , image: UIImage)->()){
        if self.pages != nil && self.pages?.count>number {
            
            if isChapterStored() {
                completion(page: number, image: UIImage(data: NSData(contentsOfFile: "\(self.docuementsDirectory())/\(self.chapter.subdirectory!)_\(type!)/\(chapter.subdirectory!)_\(String(format: "%04d", number)).\(type!)")!)!)
            }else {
                self.downloadImageAtIndex(number, updateImage: completion)
            }
        }
    }
    
    func imageOfPage(number: Int, scale: Int,completion:(image: UIImage , page: Int)->()){
        if isChapterStored() {
            completion(image: UIImage(data: NSData(contentsOfFile: "\(self.docuementsDirectory())/\(self.chapter.subdirectory)/\(String(format: "%04d", number)).\(type!)")!)!,page: number)
        }else {
            imageDownloader.downloadImage(URLRequest: NSURLRequest(URL:NSURL(string: urlOfPage(number))!)) { response in
                if let image = response.result.value {
                    completion(image: image,page: number)
                }
            }
        }
        
    }
    
    func downloadImageAtIndex(index: Int, updateImage:(index: Int, image: UIImage)->()) -> RequestReceipt? {
        return imageDownloader.downloadImage(URLRequest: NSURLRequest(URL:NSURL(string: urlOfPage(index))!)) { response in
            if let image = response.result.value {
                updateImage(index: index, image: image)
            }
        }
        
    }
    
    //MARK: - Get Pages
    
    func getPages(completion : ([IAPage])->()) {
        if  (self.chapter.pages?.count == self.chapter.numberOfPages) && self.chapter.pages?.count != 0 {
            self.pages = self.chapter.pages
            self.pages = self.pages!.sort({Int($0.number!) < Int($1.number!)})
            self.numberOfPages = self.pages?.count
            return completion(self.pages!)
        }
        let scandataURL = Constants.URL.ScandataURL(self.chapter).urlString
        return getPages(scandataURL, completion: completion)
    }
    
    func getPages(url: String, completion : ([IAPage])->()) {
        Alamofire.request(Utils.requestWithURL(url)).response { (request, response, data, error) in
            do{
                let tbxml =  try TBXML(XMLData: data, error: ())
                let rootEl = tbxml.rootXMLElement
                let pageData = TBXML.childElementNamed("pageData", parentElement: rootEl)
                if pageData == nil {
                    if url != Constants.URL.ScandataURLZipPreview(self.chapter).urlString {
                        let url = Constants.URL.ScandataURLZipPreview(self.chapter).urlString
                        return self.getPages(url, completion: completion)
                    }else {
                        return completion([])
                    }
                }
                var  pageElement = TBXML.childElementNamed("page", parentElement: pageData)
                self.pages = []
                while pageElement != nil{
                        self.pages!.append(IAPage(number: TBXML.valueOfAttributeNamed("leafNum", forElement: pageElement), chapter: self.chapter, isBookmarked: false))
                        pageElement = TBXML.nextSiblingNamed("page", searchFromElement: pageElement)
                }
                self.pages = self.pages?.sort({Int($0.number!) < Int($1.number!)})
                self.numberOfPages = self.pages?.count
                completion(self.pages!)
            } catch let error as NSError {
                print("Parse scandata xml failed: \(error.localizedDescription)")
            }
        }
    }
    
    func pageAtIndex(index: Int) -> IAPage? {
        if let pages = self.pages {
            return pages[index]
        }
        return nil
    }
    
    //MARK: - Cancel Requests
    
    func cancelAllRequests() {
        for request in self.requests! {
            request.cancel()
        }
        self.requests?.removeAll()
    }
    
    
    //MARK: - Helpers
    func docuementsDirectory()->String {
        let paths =  NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    func isChapterStored()->Bool {
        return Chapter.chapterDownloadStatus(chapter.name!, itemIdentifier: chapter.file!.archiveItem!.identifier!).isDownloaded
    }
}
