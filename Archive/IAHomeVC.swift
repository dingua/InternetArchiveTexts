//
//  IAHomeVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/16/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

@objc
class IAHomeVC: UIViewController,IARootVCProtocol,UISearchBarDelegate,UIGestureRecognizerDelegate {
    
    var listBooksVC: IAItemsListVC?
    var searchTimer: NSTimer?
    
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "bookList" {
            self.listBooksVC = segue.destinationViewController as? IAItemsListVC
        }
    }
    
    //MARK: - UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if let timer = searchTimer {
            timer.invalidate()
        }
        searchTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(IAHomeVC.search), userInfo: nil, repeats: false)

    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    //MARK: - Search
    
    func search() {
        if let text = self.searchBar.text {
            listBooksVC!.loadList(text, type: .Text)
        }
    }
    
    //MARK: IBAction
    
    @IBAction func showSortList(sender: AnyObject) {
        let sortListVC = self.storyboard!.instantiateViewControllerWithIdentifier("sortListVC") as! IASortListVC
        sortListVC.transitioningDelegate = listBooksVC!.sortPresentationDelegate;
        sortListVC.modalPresentationStyle = .Custom;
        sortListVC.delegate = listBooksVC
        if let selectedSortOption = listBooksVC!.selectedSortDescriptor {
            sortListVC.selectedOption = selectedSortOption
        }
        self.presentViewController(sortListVC, animated:true, completion:nil)
    }
    
    @IBAction func changeSortDirection(sender: AnyObject) {
        let button = sender as! UIBarButtonItem
        listBooksVC!.descendantSort = !listBooksVC!.descendantSort
        if let selectedSort = listBooksVC!.selectedSortDescriptor {
            listBooksVC!.selectedSortDescriptor = selectedSort
        }
        if listBooksVC!.descendantSort == true {
            button.image = UIImage(named: "down_sort")
        }else {
            button.image = UIImage(named: "up_sort")
        }
    }
    
    func logoutAction() {
        logout()
    }
}
