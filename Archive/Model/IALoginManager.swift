//
//  IALoginManager.swift
//  Archive
//
//  Created by Mejdi Lassidi on 4/17/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class IALoginManager: NSObject {
    static let accountLoginURL = "https://archive.org/account/login.php"
    static let accountS3URL = "https://archive.org/account/s3.php?output_json=1"

    class func login(username: String/*, password: String*/) {
//        
//        getUserId(username) { userid in
//            print ("user id = \(userid)")
//            NSUserDefaults.standardUserDefaults().setObject(userid , forKey: "userid")
//        }
//        
//        Alamofire.request(.POST, accountLoginURL,parameters: ["username":"mejdi.dingua@gmail.com","password":"zouhour","action":"login","remember":"CHECKED"]).response(completionHandler: { (_, response, _, _) in
//            if let
//                headerFields = response?.allHeaderFields as? [String: String],
//                URL = response?.URL
//            {
//                let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: URL)
//                print(cookies)
//            }

            Alamofire.request(.GET, accountS3URL).responseJSON(completionHandler: { response in
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")

                    let key = JSON.valueForKey("key")
                    if let key = key {
                        print("key access \(key.valueForKey("s3accesskey")!)")
                        NSUserDefaults.standardUserDefaults().setObject(key.valueForKey("s3accesskey"), forKey: "accesskey")
                        NSUserDefaults.standardUserDefaults().setObject(key.valueForKey("s3secretkey"), forKey: "secretkey")

                    }
                    getUserId(username) { userid in
                        print ("user id = \(userid)")
                        NSUserDefaults.standardUserDefaults().setObject(userid , forKey: "userid")
                    }
                    
                    addBookmark("FP152980s", title: "FP152980s", completion: { _ in
                        
                    })
                }
            })
//        })
    }
    
    class func getUserId(username: String, completion: String -> ()) {
        let uploader = username.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let searchURL = "https://archive.org/search.php?query=uploader:\(uploader)"
        Alamofire.request(.GET, searchURL).response { (_, response, data, _) in
            var datastring = NSString(data: data!, encoding: NSUTF8StringEncoding)
            let range = datastring?.rangeOfString("details/fav-")
            if let range = range {
                datastring = datastring?.substringFromIndex(range.location+range.length)
                let endRange = datastring?.rangeOfString("\">")
                if let endRange = endRange {
                    datastring = datastring?.substringToIndex(endRange.location)
                    completion("\(datastring!)")
                }
            }
        }
    }
    
    class func addBookmark(bookId: String, title: String, completion: String -> ()) {
        let bookmarkURL = "https://archive.org/bookmarks.php?add_bookmark=1&mediatype=texts&identifier=\(bookId)&title=\(title)&output=json"
        Alamofire.request(.GET, bookmarkURL).responseJSON (completionHandler: { response in
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
        })
    }

}
