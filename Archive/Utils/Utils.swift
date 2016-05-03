//
//  Utils.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/31/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import Alamofire
import ReachabilitySwift

class Utils {
    static func isiPad()->Bool {
        return (UI_USER_INTERFACE_IDIOM() == .Pad)
    }
    
    static func isLoggedIn() -> Bool {
        return NSUserDefaults.standardUserDefaults().stringForKey("userid") != nil
    }
    
    static func suitableCacheConfiguration()->NSURLRequestCachePolicy {
        do {
            if try Reachability.reachabilityForInternetConnection().isReachable() {
                return .ReloadIgnoringLocalCacheData
            }else {
                return .ReturnCacheDataElseLoad
            }
        } catch {
            return .ReloadIgnoringLocalCacheData
        }
     }
    
    static func requestWithURL(url: String)->NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        request.cachePolicy = Utils.suitableCacheConfiguration()
        return request
    }
}


extension String {
    func allowdStringForURL() -> String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!

    }
}