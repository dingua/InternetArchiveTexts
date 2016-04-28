//
//  IABasicVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 4/26/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

@objc

protocol IARootVCProtocol: class {
    optional func updateNavigationItem()
    @objc optional func logout()
    @objc  func logoutAction()

}

extension IARootVCProtocol where Self: UIViewController{
    func updateNavigationItem() {
        if Utils.isLoggedIn() {
            let logoutBtn = UIBarButtonItem( image: UIImage(named: "logout"), landscapeImagePhone: nil, style: .Plain, target: self, action: #selector(IARootVCProtocol.logoutAction))
            self.navigationItem.leftBarButtonItem = logoutBtn
        }else {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    func logout() {
        let alertView = UIAlertController(title: "Logout", message: "Do you want to logout ?", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (_) in
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "accesskey")
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "secretkey")
            NSUserDefaults.standardUserDefaults().setObject(nil , forKey: "userid")
            if  let loginCookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string: "https://archive.org/account/login.php")!) {
                for cookie in loginCookies {
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
                }
            }
            self.navigationItem.leftBarButtonItem = nil
            NSNotificationCenter.defaultCenter().postNotificationName(notificationUserDidLogout, object: nil)
        }))
        alertView.addAction(UIAlertAction(title: "No", style: .Cancel, handler: {_ in}))
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
}