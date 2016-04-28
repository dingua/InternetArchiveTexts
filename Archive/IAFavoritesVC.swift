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
    var itemsListVC : IAItemsListVC?
    var loginVC: IAFavouriteLoginVC?
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IAFavoritesVC.userDidLogin), name: notificationUserDidLogin, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IAFavoritesVC.userDidLogout), name: notificationUserDidLogout, object: nil)

        // Do any additional setup after loading the view.
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
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "favoritesList" {
            itemsListVC = segue.destinationViewController as? IAItemsListVC
            if let username = NSUserDefaults.standardUserDefaults().stringForKey("userid") {
                itemsListVC!.loadList("fav-\(username)", type: .Collection)
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
    
//    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
//        if Utils.isLoggedIn() {
//            return identifier == "favoritesList"
//        } else {
//            return identifier == "favoritesLogin"
//        }
//    }
//    
    // MARK: Helper
    
    func userDidLogin() {
        updateNavigationItem()
        if itemsListVC != nil {
            favouriteLoginContainerView.hidden = true
            favouriteListContainerView.hidden = false
            if let username = NSUserDefaults.standardUserDefaults().stringForKey("userid") {
                itemsListVC!.loadList("fav-\(username)", type: .Collection)
            }
        }else {
            self.performSegueWithIdentifier("favoritesList", sender: nil)
        }
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
    
    //MARK: - IARootVCProtocol
    
    func logoutAction() {
        logout()
    }


}
