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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IAFavoritesVC.userDidLogin), name: notificationUserDidLogin, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IAFavoritesVC.userDidLogout), name: notificationUserDidLogout, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IAFavoritesVC.bookmarkChanged), name: notificationBookmarkAdded, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IAFavoritesVC.bookmarkChanged), name: notificationBookmarkRemoved, object: nil)

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
//                itemsListVC!.isFavouriteList = true
//                itemsListVC!.loadList("fav-\(username)", type: .Collection)
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
