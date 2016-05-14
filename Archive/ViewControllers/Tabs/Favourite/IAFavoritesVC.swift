//
//  IAFavoritesVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 4/20/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IAFavoritesVC: UIViewController, IARootVCProtocol {

    @IBOutlet weak var favouriteListContainerView: UIView!
    @IBOutlet weak var favouriteLoginContainerView: UIView!
    var itemsListVC : IAFavouriteListVC?
    var loginVC: IAFavouriteLoginVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForNotification(notificationUserDidLogin,   action: .userDidLogin)
        registerForNotification(notificationUserDidLogout,  action: .userDidLogout)
        registerForNotification(notificationBookmarkAdded,  action: .bookmarkChanged)
        registerForNotification(notificationBookmarkRemoved,action: .bookmarkChanged)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationItem()
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
            itemsListVC = segue.destinationViewController as? IAFavouriteListVC
            if let _ = NSUserDefaults.standardUserDefaults().stringForKey("userid") {
                itemsListVC!.title = "My Favorites"
                favouriteLoginContainerView.hidden = true
                favouriteListContainerView.hidden = false
            }
        }else if segue.identifier == "favoritesLogin" {
            loginVC = segue.destinationViewController as? IAFavouriteLoginVC
            favouriteLoginContainerView.hidden = false
            favouriteListContainerView.hidden = true
        }
    }
    
    // MARK: Helper
    
    func userDidLogin() {
        updateNavigationItem()
        favouriteLoginContainerView.hidden = true
        favouriteListContainerView.hidden = false
    }

    func userDidLogout() {
        updateNavigationItem()
        if loginVC != nil{
            favouriteLoginContainerView.hidden = false
            favouriteListContainerView.hidden = true
        }else {
            self.performSegueWithIdentifier("favoritesLogin", sender: nil)
        }
    }
    
    
    func bookmarkChanged() {
//        itemsListVC!.reloadList()
    }
    
    //MARK: - IARootVCProtocol
    
    func logoutAction() {
        logout()
    }
}

private extension Selector {
    static let userDidLogin     = #selector(IAFavoritesVC.userDidLogin)
    static let userDidLogout    = #selector(IAFavoritesVC.userDidLogout)
    static let bookmarkChanged  = #selector(IAFavoritesVC.bookmarkChanged)
}
