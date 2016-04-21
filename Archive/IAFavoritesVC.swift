//
//  IAFavoritesVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 4/20/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IAFavoritesVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "favoritesList" {
            if let username = NSUserDefaults.standardUserDefaults().stringForKey("userid") {
                            let vc  = segue.destinationViewController as! IAItemsListVC
                            vc.loadList("fav-\(username)", type: .Collection)
                            vc.title = "My Favorites"
            }
        }
    }

}
