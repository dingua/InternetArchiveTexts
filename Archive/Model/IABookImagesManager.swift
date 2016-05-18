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
    
    var file: File
    var chapterIndex: Int
    var chapter : Chapter
    var type : String?
    
    let imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .FIFO,
        maximumActiveDownloads: 4,
        imageCache: AutoPurgingImageCache()
    )
    
    var requests : Array<Alamofire.Request>?
    var pages : [Page]?
    private var _numberOfPages : Int?
    var numberOfPages : Int? {
        get {
            if let numberOfPages = self._numberOfPages {
                return numberOfPages
            }
            if (self.chapter.isDownloaded?.boolValue)! && chapter.numberOfPages?.integerValue != 0 {
                    return chapter.numberOfPages?.integerValue
                }else {
                    return getNumberPages()
                }
        }
        set {
            if self.chapter.numberOfPages?.integerValue != newValue {
                if let newValue = newValue {
                    self.chapter.numberOfPages = NSNumber(integer: newValue)
                    if self.chapter.managedObjectContext != nil {
                        do{
                            try self.chapter.managedObjectContext?.save()
                        }catch let error as NSError {
                            print("couldn't save \(error.localizedDescription)")
                        }
                    }
                }
            }
            self._numberOfPages = newValue
        }
    }
    
    //MARK: - Initializer
    
    init(file : File, chapterIndex : Int) {
        
        self.file = file
        self.chapterIndex = chapterIndex
        self.chapter = self.file.chapters!.sort({$0.name < $1.name})[chapterIndex] as! Chapter
        self.type = self.chapter.type?.rawValue.lowercaseString
        self.requests = Array()
    }
    
    //MARK: - Download Pages
    
    func urlOfPage(number: Int) -> String{
        return urlOfPage(Int(pages![number].number!)!,scale: 2)
    }
    
    func urlOfPage(number: Int, scale: Int) -> String{
        return "https://\(file.server!)\(readerMethod)zip=\(file.directory!)/\(chapter.subdirectory!)_\(type!).zip&file=\(chapter.subdirectory!)_\(type!)/\(chapter.subdirectory!)_\(String(format: "%04d", number)).\(type!)&scale=\(scale)".allowdStringForURL()
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
    
    //MARK: - Get Number Of Pages
    
    func getNumberPages() -> Int? {
        var text : String?
        if let url = NSURL(string: "https://\(file.server!)\(file.directory!)/\(chapter.scandata!)".allowdStringForURL()) {
            do{
                text = try String(contentsOfURL: url)
                text = text!.substringFromIndex((text!.rangeOfString("<leafCount>")?.endIndex)!)
                text = text!.substringToIndex((text!.rangeOfString("</leafCount>")?.startIndex)!)
            }catch let error as NSError {
                print("Get content url failed: \(error.localizedDescription)")
            }
        }
        if let text = text {
            self._numberOfPages = Int(text)
        }
        return self._numberOfPages
    }
    
    //MARK: - Get Pages
    
    func getPages(completion : ([Page])->()) {
        if  (self.chapter.pages?.count == self.chapter.numberOfPages?.integerValue) {
            self.pages = self.chapter.pages?.allObjects as? [Page]
            self.pages = self.pages!.sort({Int($0.number!) < Int($1.number!)})
            return completion(self.pages!)
        }
        let scandataURL = "https://\(file.server!)\(file.directory!)/\(chapter.scandata!)".allowdStringForURL()
        Alamofire.request(Utils.requestWithURL(scandataURL)).response { (request, response, data, error) in
            do{
                let tbxml =  try TBXML(XMLData: data, error: ())
                let rootEl = tbxml.rootXMLElement
                let pageData = TBXML.childElementNamed("pageData", parentElement: rootEl)
                var  pageElement = TBXML.childElementNamed("page", parentElement: pageData)
                self.pages = []
                var managedObjectContext: NSManagedObjectContext?
                let temporary = self.chapter.managedObjectContext == nil
                if !temporary {
                    managedObjectContext = CoreDataStackManager.sharedManager.managedObjectContext
                }else {
                    managedObjectContext = try CoreDataStackManager.sharedManager.createPrivateQueueContext()
                }
                while pageElement != nil{
                    if let page = Page.createPage(TBXML.valueOfAttributeNamed("leafNum", forElement: pageElement), chapter: self.chapter, isBookmarked: false, managedObjectContext: managedObjectContext!, temporary: temporary) {
                        self.pages!.append(page)
                        pageElement = TBXML.nextSiblingNamed("page", searchFromElement: pageElement)
                    }
                }
                self.pages = self.pages?.sort({Int($0.number!) < Int($1.number!)})
                completion(self.pages!)
            } catch let error as NSError {
                print("Parse scandata xml failed: \(error.localizedDescription)")
            }
        }
    }
    
    func pageAtIndex(index: Int) -> Page? {
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
    
    //MARK: - Download zip
    
    func downloadZip()->Request {
        let destination = Alamofire.Request.suggestedDownloadDestination(
            directory: .CachesDirectory,
            domain: .UserDomainMask
        )
        
        return Alamofire.download(.GET, "https://\(file.server!)\(file.directory!)/\(chapter.subdirectory!)_\(type!).zip".allowdStringForURL(), destination: destination)
            .response { request, response, _, error in
                SSZipArchive.unzipFileAtPath((destination(NSURL(string: "")!, response!).absoluteString as NSString).substringFromIndex(7), toDestination: "\(self.docuementsDirectory())")
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "\(self.chapter.subdirectory!)_\(self.type!)")
        }
    }
    
    
    //MARK: - Helpers
    func docuementsDirectory()->String {
        let paths =  NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    func isChapterStored()->Bool {
        return chapter.isDownloaded?.boolValue == true
    }
}
