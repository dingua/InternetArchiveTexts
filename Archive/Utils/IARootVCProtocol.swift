//
//  IABasicVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 4/26/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

@objc protocol IARootVCProtocol: class {
    optional func updateNavigationItem()
    optional func logout()
    func logoutAction()
}

extension IARootVCProtocol where Self: UIViewController{
    func updateNavigationItem() {
        guard Utils.isLoggedIn() else {
            self.navigationItem.leftBarButtonItem = nil
            return
        }
        
        let logoutBtn = UIBarButtonItem(image: UIImage(named: "logout"), style: .Plain, target: self, action: #selector(IARootVCProtocol.logoutAction))
        self.navigationItem.leftBarButtonItem = logoutBtn
    }
    
    func logout() {
        let alertView = UIAlertController(title: "Logout", message: "Do you want to logout?", preferredStyle: .Alert)
        
        alertView.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { _ in
            IALoginManager.logout()
            self.navigationItem.leftBarButtonItem = nil
        }))
        
        alertView.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
    }
}
