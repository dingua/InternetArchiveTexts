//
//  Utils.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/31/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class Utils: NSObject {
    static func isiPad()->Bool {
        return (UI_USER_INTERFACE_IDIOM() == .Pad)
    }
    
    static func isLoggedIn() -> Bool {
        return NSUserDefaults.standardUserDefaults().stringForKey("userid") != nil
    }
}


extension String {
    func allowdStringForURL() -> String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!

    }
}