//
//  IAItemsListVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/16/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import AlamofireImage
import DGActivityIndicatorView

private let itemCollectionCellIdentifier = "itemCollectionCell"
private let reuseIdentifier = "BookSearchCell"

enum IABookListType {
    case Text
    case Creator
    case Collection
}

class IAItemsListVC: UICollectionViewController,IASortListDelegate {
   
    //***** Properties ************
    
    let itemsPerPage = 12
    var currentPage = 0
    var isFavouriteList = false
    var searchManager = IAItemsManager()
    var items = NSMutableArray()
    var searchText : String?
    var collectionTitle: String?
    var type: IABookListType?

    var isLoading = false

    lazy var activityIndicatorView = DGActivityIndicatorView(type: .ThreeDots, tintColor: UIColor.blackColor())

    var creatorSelectionCompletion: ((String) -> ())!
    var collectionSelectionCompletion: ((String) -> ())!
    var sortPresentationDelegate =  IASortPresentationDelgate()
   
    //sort option in which we base our request
    var sortOption: IASearchSortOption! {
        didSet {
            if let searchText = self.searchText, type = self.type{
                self.loadList(searchText, type: type)
            }
        }
    }
    
    //sort option selected From List Of IASortListVC
    var selectedSortDescriptor : IASortOption? {
        didSet {
            switch (selectedSortDescriptor!) {
            case .Downloads:
                sortOption = descendantSort ? .DownloadsDescendant : .DownloadsAscendant
                break
            case .ArchivedDate:
                sortOption = descendantSort ? .ArchivedDatedescendant : .ArchivedDateAscendant
                break
            case .PublishedDate:
                sortOption = descendantSort ? .PublishedDatedescendant : .PublishedDateAscendant
                break
            case .ReviewedDate:
                sortOption = descendantSort ? .ReviewedDatedescendant : .ReviewedDateAscendant
                break
            case .Title:
                sortOption  = descendantSort ? .TitleDescendant : .TitleAscendant
                break
            }

        }
    }
    var descendantSort: Bool = true

    //**********************************
    
    //MARK: - Initializer
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        creatorSelectionCompletion = { [weak self]creator in
            if let mySelf = self {
                if mySelf.searchText == nil || mySelf.type != .Creator || mySelf.searchText != creator {
                    let vc = mySelf.storyboard?.instantiateViewControllerWithIdentifier("bookListVC") as! IAItemsListVC
                    vc.loadList(creator, type: .Creator)
                    mySelf.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        collectionSelectionCompletion = { [weak self]collection in
            if let mySelf = self {
                if mySelf.searchText == nil || mySelf.type != .Collection || mySelf.searchText != collection {
                    let vc = mySelf.storyboard?.instantiateViewControllerWithIdentifier("bookListVC") as! IAItemsListVC
                    vc.loadList(collection, type: .Collection)
                    mySelf.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        sortOption = .DownloadsDescendant
        selectedSortDescriptor = .Downloads
    }

    //MARK: - Search
    
    func loadList(searchText: String, type: IABookListType) {
        self.searchText = searchText
        self.type = type
        self.items.removeAllObjects()
        self.currentPage = 0
        self.collectionView?.reloadData()
        if searchText.stringByReplacingOccurrencesOfString(" ", withString: "") != "" {
            if !isFavouriteList {
                loadMore()
            }else {
                loadBookmarks()
            }
        }
    }

    func loadMore() {
        guard !isFavouriteList else {return}
        if !isLoading {
            self.addLoadingView()
            switch type {
            case IABookListType.Text?:
                searchManager.searchBooksWithText(searchText!,count: itemsPerPage, page: currentPage+1,sortOption:self.sortOption) { [weak self]books in
                    if let mySelf = self {
                        if books.count>0 {
                            mySelf.currentPage+=1
                        }
                        mySelf.items.addObjectsFromArray(books as [AnyObject])
                        mySelf.synchronizeFavourites()
                        mySelf.collectionView?.reloadData()
                        mySelf.removeLoadingView()
                        
                    }
                }
                break
            case IABookListType.Creator?:
                searchManager.searchBookOfCreator(searchText!,count: itemsPerPage, page: currentPage+1,sortOption:self.sortOption) { [weak self]books in
                    if let mySelf = self {
                        if books.count>0 {
                            mySelf.currentPage+=1
                        }
                        mySelf.items.addObjectsFromArray(books as [AnyObject])
                        mySelf.synchronizeFavourites()
                        mySelf.collectionView?.reloadData()
                        mySelf.removeLoadingView()
                    }
                }
                break
            case IABookListType.Collection?:
                searchManager.searchCollectionsAndTexts(searchText!, hidden: false, count: itemsPerPage, page: currentPage+1,sortOption:self.sortOption) { [weak self] items in
                    if let mySelf = self {
                        if items.count>0 {
                            mySelf.currentPage+=1
                        }
                        mySelf.items.addObjectsFromArray(items as [AnyObject])
                        mySelf.synchronizeFavourites()
                        mySelf.collectionView?.reloadData()
                        mySelf.removeLoadingView()
                    }
                }
                break
            default:
                break
            }
        }
    }
    
    func loadBookmarks() {
        self.addLoadingView()
        IABookmarkManager.getBookmarks(NSUserDefaults.standardUserDefaults().stringForKey("userid")!, completion: {[weak self] items in
            if let mySelf = self {
                mySelf.items.addObjectsFromArray(items as [AnyObject])
                mySelf.synchronizeFavourites()
                mySelf.collectionView?.reloadData()
                mySelf.removeLoadingView()
            }
            })
        
    }
    
    func reloadList() {
        currentPage = 0
        loadList(self.searchText!, type: self.type!)
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row] as! ArchiveItemData
        if item.mediatype == "collection" {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(itemCollectionCellIdentifier, forIndexPath: indexPath) as! IACollectionsExploreViewCell
            cell.configureWithItem(items[indexPath.row] as! ArchiveItemData)
            return cell
        }else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! IAItemListCellView
            cell.configureWithItem(item, creatorCompletion:  creatorSelectionCompletion, collectionCompletion: collectionSelectionCompletion)
            cell.favouriteSelectionCompletion = {
                if !item.isFavourite() {
                    IABookmarkManager.addBookmark(item.identifier!, title: item.title!, completion: { message in
                        self.collectionView?.reloadItemsAtIndexPaths([indexPath])
                    })
                    
                }else {
                    IABookmarkManager.deleteBookmark(item.identifier!, completion: { bookId in
                        if !self.isFavouriteList {
                            self.collectionView?.reloadItemsAtIndexPaths([indexPath])
                        }
                    })
                    
                }
            }
            return cell
        }
    }

    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let item = items[indexPath.row] as! ArchiveItemData
            if item.mediatype == "collection" {
                return Utils.isiPad() ? CGSizeMake(235, 394) : CGSizeMake(min(self.view.frame.size.width/2-10,self.view.frame.size.height/2-10), 300)
            }else {
                return Utils.isiPad() ? CGSizeMake(235, 394) : CGSizeMake(min(self.view.frame.size.width/2-10,self.view.frame.size.height/2-10), 300)
            }
    }

    // MARK: - UIScrollViewDelegate

    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
        if (bottomEdge >= scrollView.contentSize.height) {
            self.loadMore()
        }
    }
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCollectionItems" {
            let selectedIndex = self.collectionView?.indexPathForCell(sender as! IACollectionsExploreViewCell)
            let vc  = segue.destinationViewController as! IAItemsListVC
            let collectionData = items[selectedIndex!.row] as! ArchiveItemData
            vc.loadList(collectionData.identifier!, type: .Collection)
        } else if segue.identifier == "showReader" {
            let selectedIndex = self.collectionView?.indexPathForCell(sender as! IAItemListCellView)
            let bookReaderNavController = segue.destinationViewController as! UINavigationController
            let bookReader = bookReaderNavController.topViewController as! IAReaderVC
            bookReader.bookIdentifier = (items[selectedIndex!.row] as! ArchiveItemData).identifier!
        }
    }

    //MARK: - Helpers
    
    func addLoadingView() {
        isLoading = true
        self.view.addSubview(activityIndicatorView)
        self.activityIndicatorView.startAnimating()
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraint(NSLayoutConstraint(item: self.activityIndicatorView  , attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
        
        self.view.addConstraint(NSLayoutConstraint(item:  self.activityIndicatorView, attribute: .CenterY, relatedBy: .Equal, toItem:self.view , attribute: .CenterY, multiplier: 1.0, constant: 0))
    }
    
    func removeLoadingView() {
        isLoading = false
        self.activityIndicatorView.stopAnimating()
        self.activityIndicatorView.removeFromSuperview()
    }
    
    //MARK: IBAction
    
    @IBAction func showSortList(sender: AnyObject) {
        let sortListVC = self.storyboard!.instantiateViewControllerWithIdentifier("sortListVC") as! IASortListVC
        sortListVC.transitioningDelegate = sortPresentationDelegate;
        sortListVC.modalPresentationStyle = .Custom;
        sortListVC.delegate = self
        if let selectedSortOption = self.selectedSortDescriptor {
            sortListVC.selectedOption = selectedSortOption
        }
        self.presentViewController(sortListVC, animated:true, completion:nil)
    }
    
    @IBAction func changeSortDirection(sender: AnyObject) {
        let button = sender as! UIBarButtonItem
        self.descendantSort = !self.descendantSort
        if let selectedSort = self.selectedSortDescriptor {
            self.selectedSortDescriptor = selectedSort
        }
        if self.descendantSort == true {
            button.image = UIImage(named: "down_sort")
        }else {
            button.image = UIImage(named: "up_sort")
        }
    }
  
    //MARK: IASortListDelegate
    
    func sortListDidSelectSortOption(option: IASortOption) {
        self.selectedSortDescriptor = option
    }
    
    func synchronizeFavourites() {
        if isFavouriteList {
           IABookmarkManager.synchronizeFavourites(items)
        }
    }
    

}