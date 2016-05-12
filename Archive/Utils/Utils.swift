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
    
    static func docuementsDirectory()->String {
        let paths =  NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
}

// MARK: - Extensions

extension String {
    func allowdStringForURL() -> String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!

    }
}

extension UIImage {
    func imageWithTintColor(color : UIColor)->UIImage? {
        var image = self.imageWithRenderingMode(.AlwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(self.size, false, image.scale);
        color.set()
        image.drawInRect(CGRectMake(0, 0, self.size.width, image.size.height))
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return  image
    }
}

extension UIViewController {
    func registerForNotification(name: String, action: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: action, name: name, object: nil)
    }
}
