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
    case Uploader
    case Subject
}

class IAItemsListVC: UICollectionViewController,IASortListDelegate {
    
    //***** Properties ************
    
    let itemsPerPage = 36
    var currentPage = 0
    var searchManager = IAItemsManager()
    var items = [ArchiveItem]()
    var searchText : String?
    var collectionTitle: String?
    var type: IABookListType?
    
    var isLoading = false
    
    lazy var activityIndicatorView = DGActivityIndicatorView(type: .ThreeDots, tintColor: UIColor.blackColor())
    
    var sortPresentationDelegate =  IASortPresentationDelgate()
    var bookDetailsPresentationDelegate = IABookDetailsPresentationDelgate()
    //sort option in which we base our request
    var sortOption: IASearchSortOption! {
        didSet {
            if let searchText = self.searchText, type = self.type {
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
            case .Relevance:
                sortOption = .Relevance
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
        sortOption = .DownloadsDescendant
        selectedSortDescriptor = .Downloads
    }
    
    //MARK: - Search
    
    func loadList(searchText: String, type: IABookListType) {
        self.searchText = searchText
        self.type = type
        self.items.removeAll()
        self.currentPage = 0
        self.collectionView?.reloadData()
        if searchText.stringByReplacingOccurrencesOfString(" ", withString: "") != "" {
            loadMore()
        }
    }
    
    func loadMore() {
        if !isLoading || currentPage == 0 {//if is not already loading next page  or it is loading the first page then load
            self.addLoadingView()
            
            switch type! {
            case .Text:
                searchManager.searchBooksWithText(searchText!,
                                                  count: itemsPerPage,
                                                  page: currentPage + 1,
                                                  sortOption: sortOption)
                { [weak self] books in
                    self?.addItems(books)
                }
                break
            case .Creator:
                searchManager.searchBookOfCreator(searchText!,
                                                  count: itemsPerPage,
                                                  page: currentPage + 1,
                                                  sortOption: sortOption)
                { [weak self] books in
                    self?.addItems(books)
                }
                break
            case .Collection:
                searchManager.searchCollectionsAndTexts(searchText!,
                                                        hidden: false,
                                                        count: itemsPerPage,
                                                        page: currentPage+1,
                                                        sortOption: sortOption)
                { [weak self] items in
                    self?.addItems(items)
                }
                break
            case .Uploader:
                searchManager.searchCollectionsAndTexts(uploader: searchText!,
                                                        hidden: false,
                                                        count: itemsPerPage,
                                                        page: currentPage+1,
                                                        sortOption: sortOption)
                { [weak self] items in
                    self?.addItems(items)
                }
                break
            case .Subject:
                searchManager.searchCollectionsAndTexts(subject: searchText!,
                                                        hidden: false,
                                                        count: itemsPerPage,
                                                        page: currentPage+1,
                                                        sortOption: sortOption)
                { [weak self] items in
                    self?.addItems(items)
                }
                break
            }
        }
    }
    
    func addItems(items: [ArchiveItem]) {
        if !items.isEmpty {
            currentPage+=1
        }
        self.items.appendContentsOf(items)
        collectionView?.reloadData()
        removeLoadingView()
    }
    
    func reloadList() {
        currentPage = 0
        loadList(self.searchText!, type: self.type!)
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row]
        if item.mediatype == "collection" {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(itemCollectionCellIdentifier, forIndexPath: indexPath) as! IACollectionsExploreViewCell
            cell.configureWithItem(items[indexPath.row])
            return cell
        }else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! IAItemListCellView
            cell.configureWithItem(item)
            cell.favoriteClosure = {
                if !Utils.isLoggedIn() {
                    self.presentLoginscreen().dismissCompletion = {
                        self.triggerFavorite(item, atIndexPath: indexPath)
                    }
                    return
                }
                self.triggerFavorite(item, atIndexPath: indexPath)

            }
            cell.detailsClosure = {
                let bookDetails = UIStoryboard(name: "BookDetails", bundle: nil).instantiateInitialViewController() as! IABookDetailsVC
                bookDetails.book = item
                if Utils.isiPad() {
                    bookDetails.transitioningDelegate = self.bookDetailsPresentationDelegate
                    bookDetails.modalPresentationStyle = .Custom
                    bookDetails.pushListOnDismiss = {text, type in
                        guard self.searchText != text || self.type != type else {return}
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let itemsListVC = storyboard.instantiateViewControllerWithIdentifier("bookListVC") as! IAItemsListVC
                        itemsListVC.loadList(text ?? "", type: type)
                        self.navigationController?.pushViewController(itemsListVC, animated: true)
                    }
                    bookDetails.pushReaderOnChapter = {chapterIndex in
                        self.showReader(item, atChapterIndex: chapterIndex)
                    }
                    self.presentViewController(bookDetails, animated: true, completion: nil)
                }else {
                    self.navigationController?.pushViewController(bookDetails, animated: true)
                }
            }
            return cell
        }
    }
    
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        return Utils.isiPad() ? CGSizeMake(150, 250) : CGSizeMake(100, 135)
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
            let collectionData = items[selectedIndex!.row]
            vc.loadList(collectionData.identifier!, type: .Collection)
        } else if segue.identifier == "showReader" {
            let selectedIndex = self.collectionView?.indexPathForCell(sender as! IAItemListCellView)
            let bookReaderNavController = segue.destinationViewController as! UINavigationController
            let bookReader = bookReaderNavController.topViewController as! IAReaderVC
            let item = items[selectedIndex!.row]
            bookReader.bookIdentifier = item.identifier!
            bookReader.bookTitle = item.title
            bookReader.item = item
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
    
    func presentLoginscreen()->IALoginVC {
        let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("loginVC") as! IALoginVC
        loginVC.transitioningDelegate = sortPresentationDelegate
        loginVC.modalPresentationStyle = .Custom
        self.presentViewController(loginVC, animated: true, completion: nil)
        return loginVC
    }

    
    func showReader(item: ArchiveItem, atChapterIndex chapterIndex :Int = -1) {
        let navController = UIStoryboard(name: "Reader",bundle: nil).instantiateInitialViewController() as! UINavigationController
        let bookReader = navController.topViewController as! IAReaderVC
        bookReader.bookIdentifier = item.identifier!
        bookReader.bookTitle = item.title
        bookReader.item = item
        bookReader.didGetFileDetailsCompletion = {
            bookReader.setupReaderToChapter(chapterIndex)
        }
        self.presentViewController(navController, animated: true, completion: nil)
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
    
    func triggerFavorite(item: ArchiveItem, atIndexPath indexPath: NSIndexPath) {
        if !((item.isFavourite?.boolValue)!) {
            IAFavouriteManager.sharedInstance.addBookmark(item, completion: { message in
                self.collectionView?.reloadItemsAtIndexPaths([indexPath])
            })
            
        }else {
            IAFavouriteManager.sharedInstance.deleteBookmark(item, completion: { _ in
                self.collectionView?.reloadItemsAtIndexPaths([indexPath])
            })
            
        }
    }
    
    //MARK: IASortListDelegate
    
    func sortListDidSelectSortOption(option: IASortOption) {
        self.selectedSortDescriptor = option
    }
}