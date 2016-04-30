//
//  IAHomeVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/16/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

@objc
class IAHomeVC: UIViewController,IARootVCProtocol,UISearchBarDelegate,UIGestureRecognizerDelegate, IASortListDelegate {
    
    var listBooksVC: IAItemsListVC?
    var searchTimer: NSTimer?
    
    @IBOutlet weak var donwnUpSortButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        //At the start it will be disable as for Relevance Option there is no sort direction
        donwnUpSortButton.enabled = false
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
            self.listBooksVC?.sortOption = .Relevance
            self.listBooksVC?.selectedSortDescriptor = .Relevance
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
        sortListVC.delegate = self
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
    
    //MARK: IASortListDelegate
    
    func listOfSortOptions()->[IASortOption] {
        return [.Relevance, .Downloads,.Title,.ArchivedDate,.PublishedDate,.ReviewedDate]
    }
    
    func sortListDidSelectSortOption(option: IASortOption) {
        listBooksVC!.selectedSortDescriptor = option
        if option == .Relevance {
            donwnUpSortButton.enabled = false
        }else {
            donwnUpSortButton.enabled = true
        }
    }


}
