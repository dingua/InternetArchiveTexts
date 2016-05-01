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
    
    /************** PROPERTIES *****/
    let bookId: String!
    let serverURL: String!
    let directory: String!
    let subDirectory: String!
    let scandata: String!
    let type: String!
    var pagesOnCacheProcess = Array<Int>()
    
    let imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .FIFO,
        maximumActiveDownloads: 4,
        imageCache: AutoPurgingImageCache()
    )

    var requests : Array<Alamofire.Request>?
    var pages : [String]?
    
    //MARK: - Initializer
    
    init(identifier:String , server:String, directory:String, subdirectory:String, scandata: String, type: String) {
        self.bookId = identifier
        self.serverURL = server
        self.directory = directory
        self.subDirectory = subdirectory.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!

        self.scandata = scandata.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        self.type = type
        self.requests = Array()
    }
    
    //MARK: - Download Pages
    
    func urlOfPage(number: Int) -> String{
        return urlOfPage(Int(pages![number])!,scale: 2)
    }

    func urlOfPage(number: Int, scale: Int) -> String{
        return "https://\(serverURL)\(readerMethod)zip=\(directory)/\(subDirectory)_\(type).zip&file=\(subDirectory)_\(type)/\(subDirectory)_\(String(format: "%04d", number)).\(type)&scale=\(scale)"
    }

    func getImages(offset: Int, count:Int,updatedImage:(index: Int, image: UIImage)->() , completion:()->()) {
        let group = dispatch_group_create();
        for index in offset...offset+count {
            dispatch_group_enter(group)
            if index<0 {
                dispatch_group_leave(group)
            }else if(self.pagesOnCacheProcess.contains(index)){
                dispatch_group_leave(group)
            }else {
                self.pagesOnCacheProcess.append(index)
               let requestReceipt =  imageDownloader.downloadImage(URLRequest: NSURLRequest(URL:NSURL(string: urlOfPage(index))!)) { response in
                    if let image = response.result.value {
                        updatedImage(index: index, image: image)
                        self.pagesOnCacheProcess.removeObject(index)
                    }
                }
                if let requestReceipt = requestReceipt {
                    self.requests?.append(requestReceipt.request)
                }
            }
        }
        dispatch_group_notify(group, dispatch_get_main_queue()) { () -> Void in
            completion()
        }
    }
    
    func imageOfPage(number: Int,completion:(image: UIImage , page: Int)->()){
        if self.pages != nil && self.pages?.count>number {
            self.pagesOnCacheProcess.append(number)
            imageDownloader.downloadImage(URLRequest: NSURLRequest(URL:NSURL(string: urlOfPage(number))!)) { response in
                if let image = response.result.value {
                    completion(image: image,page: number)
                    self.pagesOnCacheProcess.removeObject(number)
                }
            }
        }
    }
    
    func imageOfPage(number: Int, scale: Int,completion:(image: UIImage , page: Int)->()){
        self.pagesOnCacheProcess.append(number)
        imageDownloader.downloadImage(URLRequest: NSURLRequest(URL:NSURL(string: urlOfPage(number))!)) { response in
            if let image = response.result.value {
                completion(image: image,page: number)
                self.pagesOnCacheProcess.removeObject(number)
            }
        }
    }

    //MARK: - Get Number Of Pages
    
    func getNumberPages() -> String? {
        var text : String?
        if let url = NSURL(string: "https://\(serverURL)\(directory)/\(scandata)") {
            do{
                text = try String(contentsOfURL: url)
                text = text!.substringFromIndex((text!.rangeOfString("<leafCount>")?.endIndex)!)
                text = text!.substringToIndex((text!.rangeOfString("</leafCount>")?.startIndex)!)
            }catch let error as NSError {
                print("Get content url failed: \(error.localizedDescription)")
                text = getNumberPagesWithoutSubdirectory()
            }
        }
        return text
    }
  
    func getNumberPagesWithoutSubdirectory() -> String? {
        var text : String?
        if let url = NSURL(string: "https://\(serverURL)\(directory)/\(scandata)") {
            do{
                text = try String(contentsOfURL: url)
                text = text!.substringFromIndex((text!.rangeOfString("<leafCount>")?.endIndex)!)
                text = text!.substringToIndex((text!.rangeOfString("</leafCount>")?.startIndex)!)
            }catch let error as NSError {
                print("Get content url failed: \(error.localizedDescription)")
            }
        }
        return text
    }
    
    //MARK: - Get Pages 
    
    func getPages(completion : ([String])->()) {
        let scandataURL = "https://\(serverURL)\(directory)/\(scandata)"
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
    
    func downloadZip() {
        let destination = Alamofire.Request.suggestedDownloadDestination(
            directory: .CachesDirectory,
            domain: .UserDomainMask
        )
        
        Alamofire.download(.GET, "https://\(serverURL)\(directory)/\(subDirectory)_\(type).zip", destination: destination)
            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                print(totalBytesRead)
            }
            .response { request, response, _, error in
                print(response)
                print("fileURL: \(destination(NSURL(string: "")!, response!))")
        }
    }
}
