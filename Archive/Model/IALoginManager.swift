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
        Alamofire.request(.GET, accountS3URL).responseJSON(completionHandler: { response in
            if let JSON = response.result.value {
                let key = JSON.valueForKey("key")
                if let key = key {
                    NSUserDefaults.standardUserDefaults().setObject(key.valueForKey("s3accesskey"), forKey: "accesskey")
                    NSUserDefaults.standardUserDefaults().setObject(key.valueForKey("s3secretkey"), forKey: "secretkey")
                }
                getUserId(username) { userid in
                    NSUserDefaults.standardUserDefaults().setObject(userid , forKey: "userid")
                    NSNotificationCenter.defaultCenter().postNotificationName("userLoggedIn", object: nil)
                }
            }
        })
    }
    
    class func getUserId(username: String, completion: String -> ()) {
        let uploader = username.allowdStringForURL()
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
    
    class func logout() {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "accesskey")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "secretkey")
        NSUserDefaults.standardUserDefaults().setObject(nil , forKey: "userid")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: favouriteListIds)
        if  let loginCookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string: "https://archive.org/account/login.php")!) {
            for cookie in loginCookies {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
            }
        }
        NSNotificationCenter.defaultCenter().postNotificationName(notificationUserDidLogout, object: nil)
    }
}
