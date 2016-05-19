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
    
    static let defs = NSUserDefaults.standardUserDefaults()
    static let notes = NSNotificationCenter.defaultCenter()
    static let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage()
    
    class func login(username: String/*, password: String*/) {
        Alamofire.request(.GET, accountS3URL).responseJSON(completionHandler: { response in
            if let JSON = response.result.value {
                if let key = JSON.valueForKey("key") {
                    defs.setObject(key.valueForKey("s3accesskey"), forKey: Constants.Keys.Access.rawValue)
                    defs.setObject(key.valueForKey("s3secretkey"), forKey: Constants.Keys.Secret.rawValue)
                }
                getUserId(username) { userid in
                    if userid?.characters.count > 0 {
                        defs.setObject(userid, forKey: Constants.Keys.UserID.rawValue)
                        notes.postNotificationName(Constants.Notification.UserDidLogin.name, object: nil)
                    }
                    // WARNING: Not handling failed login
                }
            }
        })
    }
    
    class func getUserId(username: String, completion: String? -> ()) {
        let uploader = username.allowdStringForURL()
        let searchURL = "https://archive.org/search.php?query=uploader:\(uploader)"
        
        Alamofire.request(.GET, searchURL).response { (_, response, data, _) in
            var datastring = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            if let range = datastring?.rangeOfString("details/fav-") {
                datastring = datastring?.substringFromIndex(range.location+range.length)
                
                if let endRange = datastring?.rangeOfString("\">") {
                    completion(datastring?.substringToIndex(endRange.location))
                }
            }
            
            completion(nil)
        }
    }
    
    class func logout() {
        defs.setObject(nil, forKey: Constants.Keys.Access.rawValue)
        defs.setObject(nil, forKey: Constants.Keys.Secret.rawValue)
        defs.setObject(nil, forKey: Constants.Keys.UserID.rawValue)
        defs.setObject(nil, forKey: Constants.Keys.FavoriteListIDs.rawValue)
        
        if  let loginCookies = cookies.cookiesForURL(NSURL(string: accountLoginURL)!) {
            loginCookies.forEach { cookies.deleteCookie($0) }
        }
        
        notes.postNotificationName(Constants.Notification.UserDidLogout.name, object: nil)
    }
}
