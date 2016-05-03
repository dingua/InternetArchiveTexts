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
    var pagesOnCacheProcess = Array<Int>()
    
    let imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .FIFO,
        maximumActiveDownloads: 4,
        imageCache: AutoPurgingImageCache()
    )

    var requests : Array<Alamofire.Request>?
    var pages : [String]?
    var numberOfPages : Int?
    
    //MARK: - Initializer
    
    init(file : File, chapterIndex : Int) {
        
        self.file = file
        self.chapterIndex = chapterIndex
        self.chapter = self.file.chapters![chapterIndex]
        self.type = self.chapter.type?.rawValue.lowercaseString
        self.requests = Array()
    }
    
    //MARK: - Download Pages
    
    func urlOfPage(number: Int) -> String{
        return urlOfPage(Int(pages![number])!,scale: 2)
    }

    func urlOfPage(number: Int, scale: Int) -> String{
        return "https://\(file.server!)\(readerMethod)zip=\(file.directory!)/\(chapter.subdirectory!)_\(type!).zip&file=\(chapter.subdirectory!)_\(type!)/\(chapter.subdirectory!)_\(String(format: "%04d", number)).\(type!)&scale=\(scale)"
    }

    func getImages(offset: Int, count:Int,updateImage:(index: Int, image: UIImage)->() , completion:()->()) {
        let group = dispatch_group_create();
        for index in offset...offset+count {
            dispatch_group_enter(group)
            if index<0 || self.numberOfPages!<=index{
                dispatch_group_leave(group)
            }else if(self.pagesOnCacheProcess.contains(index)){
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
        let isStored = NSUserDefaults.standardUserDefaults().boolForKey("\(self.chapter.subdirectory!)_\(type!)")
        if isStored {
            completion(image: UIImage(data: NSData(contentsOfFile: "\(self.docuementsDirectory())/\(self.chapter.subdirectory)/\(String(format: "%04d", number)).\(type!)")!)!,page: number)
        }else {
            self.pagesOnCacheProcess.append(number)
            imageDownloader.downloadImage(URLRequest: NSURLRequest(URL:NSURL(string: urlOfPage(number))!)) { response in
                if let image = response.result.value {
                    completion(image: image,page: number)
                    self.pagesOnCacheProcess.removeObject(number)
                }
            }
        }
    
    }
    
    func downloadImageAtIndex(index: Int, updateImage:(index: Int, image: UIImage)->()) -> RequestReceipt? {
        self.pagesOnCacheProcess.append(index)
        return imageDownloader.downloadImage(URLRequest: NSURLRequest(URL:NSURL(string: urlOfPage(index))!)) { response in
            if let image = response.result.value {
                updateImage(index: index, image: image)
                self.pagesOnCacheProcess.removeObject(index)
            }
        }
        
    }

    //MARK: - Get Number Of Pages
    
    func getNumberPages(chapterIndex: Int) -> String? {
        if let subdirectory = self.chapter.subdirectory , type = type {
            let isStored = NSUserDefaults.standardUserDefaults().boolForKey("\(subdirectory)_\(type)")
            if isStored {
                if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey("file_\(self.file.identifier!)") as? NSData {
                    let file =  NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as! File
                    self.numberOfPages = file.chapters![chapterIndex].numberOfPages!
                    return String (self.numberOfPages!)
                }else {
                    return getNumberPages()
                }
            }else {
                return getNumberPages()
            }
        }else {
            return getNumberPages()
        }
       
    }
  
    func getNumberPages() -> String? {
        var text : String?
        if let url = NSURL(string: "https://\(file.server!)\(file.directory!)/\(chapter.scandata!)") {
            do{
                text = try String(contentsOfURL: url)
                text = text!.substringFromIndex((text!.rangeOfString("<leafCount>")?.endIndex)!)
                text = text!.substringToIndex((text!.rangeOfString("</leafCount>")?.startIndex)!)
            }catch let error as NSError {
                print("Get content url failed: \(error.localizedDescription)")
            }
        }
        numberOfPages = Int(text!)
        return text
    }
    
    //MARK: - Get Pages 
    
    func getPages(completion : ([String])->()) {
        let scandataURL = "https://\(file.server!)\(file.directory!)/\(chapter.scandata!)"
        Alamofire.request(.GET, scandataURL).response { (request, response, data, error) in
            do{
                let tbxml =  try TBXML(XMLData: data, error: ())
                let rootEl = tbxml.rootXMLElement 
                let pageData = TBXML.childElementNamed("pageData", parentElement: rootEl)
                var  page = TBXML.childElementNamed("page", parentElement: pageData)
                self.pages = []
                while page != nil{
                    self.pages!.append(TBXML.valueOfAttributeNamed("leafNum", forElement: page))
                    page = TBXML.nextSiblingNamed("page", searchFromElement: page)
                }
                completion(self.pages!)
            } catch let error as NSError {
                print("Parse scandata xml failed: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - Cancel Requests
    
    func cancelAllRequests() {
        for request in self.requests! {
            request.cancel()
        }
        self.requests?.removeAll()
        self.pagesOnCacheProcess.removeAll()
    }
    
    //MARK: - Download zip
    
    func downloadZip()->Request {
        let destination = Alamofire.Request.suggestedDownloadDestination(
            directory: .CachesDirectory,
            domain: .UserDomainMask
        )
        
        return Alamofire.download(.GET, "https://\(file.server!)\(file.directory!)/\(chapter.subdirectory!)_\(type!).zip", destination: destination)
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
        return NSUserDefaults.standardUserDefaults().boolForKey("\(self.chapter.subdirectory!)_\(type!)")
    }
}
