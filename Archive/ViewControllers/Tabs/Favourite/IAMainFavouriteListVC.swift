//
//  IAMainFavouriteListVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/5/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IAMainFavouriteListVC: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var favouriteListContainerView: UIView!
    @IBOutlet weak var bookmarkListContainerView: UIView!
    @IBOutlet weak var downloadListContainerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        segmentControl.selectedSegmentIndex = 0
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
        
        if segue.identifier == "favoritesList" {
        
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
}
