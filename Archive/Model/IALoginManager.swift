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

    class func login(username: String, password: String) {
        Alamofire.request(.POST, accountLoginURL,parameters: ["username":username,"password":password,"action":"login","remember":"CHECKED"]).response(completionHandler: { _ in
            Alamofire.request(.GET, accountS3URL).responseJSON(completionHandler: { response in
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                    let key = JSON.valueForKey("key")
                    print("key access \(key!.valueForKey("s3accesskey")!)")
                    NSUserDefaults.standardUserDefaults().setObject(key!.valueForKey("s3accesskey"), forKey: "accesskey")
                    NSUserDefaults.standardUserDefaults().setObject(key!.valueForKey("s3secretkey"), forKey: "secretkey")
                }
            })
        })
    }
}
