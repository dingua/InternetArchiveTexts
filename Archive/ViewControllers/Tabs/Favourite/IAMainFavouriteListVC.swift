//
//  IAMainFavouriteListVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/5/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

private extension Selector {
    static let userDidLogin     = #selector(IAMainFavouriteListVC.userDidLogin)
    static let userDidLogout    = #selector(IAMainFavouriteListVC.userDidLogout)
}

class IAMainFavouriteListVC: UIViewController,IARootVCProtocol {

    lazy var segmentControl: UISegmentedControl = {
            let segmentControl = UISegmentedControl(items: ["Favourites","Downloads","Bookmarks"])
            segmentControl.selectedSegmentIndex = 0
            segmentControl.tintColor = UIColor.blackColor()
            segmentControl.addTarget(self, action: #selector(IAMainFavouriteListVC.segmentControlValueChanged(_:)), forControlEvents: .ValueChanged)
            return segmentControl
    }()
    
    @IBOutlet weak var favouriteListContainerView: UIView!
    @IBOutlet weak var bookmarkListContainerView: UIView!
    @IBOutlet weak var downloadListContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        registerForNotification(Constants.Notification.UserDidLogin.name,   action: .userDidLogin)
        registerForNotification(Constants.Notification.UserDidLogout.name,  action: .userDidLogout)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationItem()
        self.navigationItem.titleView = segmentControl
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        favouriteListContainerView.hidden = false
        downloadListContainerView.hidden = true
        bookmarkListContainerView.hidden = true
    }

    //MARK: - IBAction
    
    @IBAction func segmentControlValueChanged(sender: AnyObject) {
        
        switch (sender as! UISegmentedControl).selectedSegmentIndex {
        case 0:
            favouriteListContainerView.hidden = false
            downloadListContainerView.hidden = true
            bookmarkListContainerView.hidden = true
            break
        case 1:
            favouriteListContainerView.hidden = true
            downloadListContainerView.hidden = false
            bookmarkListContainerView.hidden = true
            break
        case 2:
            favouriteListContainerView.hidden = true
            downloadListContainerView.hidden = true
            bookmarkListContainerView.hidden = false
            break
        default:
            break
        }
    }
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "favoritesList" {}
    }
    
    //MARK: - Notification
    
    func userDidLogin() {
        updateNavigationItem()
    }
    
    func userDidLogout() {
        updateNavigationItem()
    }
    
    //MARK: - IARootVCProtocol
    
    func logoutAction() {
        logout()
    }

}
