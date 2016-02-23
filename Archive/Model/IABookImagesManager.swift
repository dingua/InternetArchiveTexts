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
    let bookId: String!
    let serverURL: String!
    let directory: String!
    let subDirectory: String!
    let scandata: String!
    let type: String!
    var pagesOnCacheProcess = Array<Int>()
    
    let imageCache =  AutoPurgingImageCache(
        memoryCapacity: 1000 * 1024 * 1024,
        preferredMemoryUsageAfterPurge: 200 * 1024 * 1024
    )
    var requests : Array<Alamofire.Request>?
    
    init(identifier:String , server:String, directory:String, subdirectory:String, scandata: String, type: String) {
        self.bookId = identifier
        self.serverURL = server
        self.directory = directory
        self.subDirectory = subdirectory.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!

        self.scandata = scandata
        self.type = type
        self.requests = Array()
    }
    
    func urlOfPage(number: Int) -> String{
        return urlOfPage(number,scale: 2)
    }

    func urlOfPage(number: Int, scale: Int) -> String{
        return "https://\(serverURL)\(readerMethod)zip=\(directory)/\(subDirectory)_\(type).zip&file=\(subDirectory)_\(type)/\(subDirectory)_\(String(format: "%04d", number)).\(type)&scale\(scale)"
    }

    func getImages(offset: Int, count:Int,updatedImage:(index: Int, image: UIImage)->() , completion:()->()) {
        let group = dispatch_group_create();
        for index in offset...offset+count {
            dispatch_group_enter(group)
            let identifier = "page_\(self.bookId)_\(String(format: "%04d", index))"
            if index<0 {
                dispatch_group_leave(group)
            }else if let _ = self.imageCache.imageWithIdentifier(identifier) {
                dispatch_group_leave(group)
            }else if(self.pagesOnCacheProcess.contains(index)){
                dispatch_group_leave(group)
            }else {
                self.pagesOnCacheProcess.append(index)
                print("download \(index)")
                let request =  Alamofire.request(.GET, urlOfPage(index))
                    .responseImage { response in
                        if let image = response.result.value {
                            self.imageCache.addImage(image,
                                withIdentifier: "page_\(self.bookId)_\(String(format: "%04d", index))")
                            updatedImage(index: index, image: image)
                            self.pagesOnCacheProcess.removeObject(index)
                            dispatch_group_leave(group)
                        }
                }
                self.requests?.append(request)
            }
        
            
        }
        dispatch_group_notify(group, dispatch_get_main_queue()) { () -> Void in
            completion()
        }
        
    }
    
    func imageOfPage(number: Int,completion:(image: UIImage , page: Int)->()){
        let identifier = "page_\(self.bookId)_\(String(format: "%04d", number))"
        
        if let image = self.imageCache.imageWithIdentifier(identifier) {
            completion(image: image,page: number)
        }else if(!self.pagesOnCacheProcess.contains(number)){
            
            self.pagesOnCacheProcess.append(number)

            print("download \(number)")
            Alamofire.request(.GET, urlOfPage(number))
                .responseImage { response in
                    if let image = response.result.value {
                        self.imageCache.addImage(image,
                            withIdentifier: identifier)
                        completion(image: image,page: number)
                        self.pagesOnCacheProcess.removeObject(number)
                    }
            }
       
        }
    }
    
    func imageOfPage(number: Int, scale: Int,completion:(image: UIImage , page: Int)->()){
        let identifier = "page_\(self.bookId)_\(String(format: "%04d", number))_scale_\(scale)"
        
        if let image = self.imageCache.imageWithIdentifier(identifier) {
            completion(image: image,page: number)
        }else if(!self.pagesOnCacheProcess.contains(number)){
            
            self.pagesOnCacheProcess.append(number)
            print("download \(number)")
            Alamofire.request(.GET, urlOfPage(number))
                .responseImage { response in
                    if let image = response.result.value {
                        self.imageCache.addImage(image,
                            withIdentifier: identifier)
                        completion(image: image,page: number)
                        self.pagesOnCacheProcess.removeObject(number)
                    }
            }
            
        }
    }

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
        if let url = NSURL(string: "https://\(serverURL)\(directory)/scandata.xml") {
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
    func cancelAllRequests() {
        for request in self.requests! {
            request.cancel()
        }
        self.requests?.removeAll()
        self.pagesOnCacheProcess.removeAll()
    }
}
