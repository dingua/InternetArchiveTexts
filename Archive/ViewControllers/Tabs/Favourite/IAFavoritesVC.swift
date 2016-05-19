//
//  IAFavoritesVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 4/20/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IAFavoritesVC: UIViewController {

    @IBOutlet weak var favouriteListContainerView: UIView!
    @IBOutlet weak var favouriteLoginContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForNotification(Constants.Notification.UserDidLogin.name,   action: .userDidLogin)
        registerForNotification(Constants.Notification.UserDidLogout.name,  action: .userDidLogout)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if Utils.isLoggedIn() {
            favouriteLoginContainerView.hidden = true
            favouriteListContainerView.hidden = false
        }else {
            favouriteLoginContainerView.hidden = false
            favouriteListContainerView.hidden = true
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "favoritesList" {
            if let _ = NSUserDefaults.standardUserDefaults().stringForKey("userid") {
                favouriteLoginContainerView.hidden = true
                favouriteListContainerView.hidden = false
            }
        }else if segue.identifier == "favoritesLogin" {
            favouriteLoginContainerView.hidden = false
            favouriteListContainerView.hidden = true
        }
    }
    
    // MARK: Helper
    
    func userDidLogin() {
        favouriteLoginContainerView.hidden = true
        favouriteListContainerView.hidden = false
    }

    func userDidLogout() {
            favouriteLoginContainerView.hidden = false
            favouriteListContainerView.hidden = true
    }
}

private extension Selector {
    static let userDidLogin     = #selector(IAFavoritesVC.userDidLogin)
    static let userDidLogout    = #selector(IAFavoritesVC.userDidLogout)
}
