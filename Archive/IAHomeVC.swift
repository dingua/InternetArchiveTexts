//
//  IAHomeVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/16/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IAHomeVC: UIViewController,UISearchBarDelegate,UIGestureRecognizerDelegate {
    
    var listBooksVC: IAItemsListVC?
    var searchTimer: NSTimer?
    
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
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
}
