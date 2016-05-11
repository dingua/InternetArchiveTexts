//
//  IATabBarController.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/3/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IATabBarController: UITabBarController {
    static let sharedInstance = (UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("iaTabbarVC") as! IATabBarController)
    var firstAppearance = true
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppearance {
            let downloadsToResume =  IADownloadsManager.sharedInstance.getChaptersInDownloadState()
            if downloadsToResume?.count > 0 {
                let alertView = UIAlertController(title: "Resume Download", message: "There are chapters where downloads are not accomplished yet, do you want to resume the downloads ?", preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (_) in
                    IADownloadsManager.sharedInstance.resumeDownloads()
                }))
                alertView.addAction(UIAlertAction(title: "No", style: .Cancel, handler: {_ in}))
                self.presentViewController(alertView, animated: true, completion: nil)
            }
            firstAppearance = false
        }
    }
}
