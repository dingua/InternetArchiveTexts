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

class IAItemsListVC: UICollectionViewController {
   
    //***** Properties ************
    
    let itemsPerPage = 12
    
    var searchManager = IAItemsManager()
    var items = NSMutableArray()
    var searchText : String?
    var collectionTitle: String?
    var type: IABookListType?

    lazy var activityIndicatorView = DGActivityIndicatorView(type: .ThreeDots, tintColor: UIColor.blackColor())

    var creatorSelectionCompletion: ((String) -> ())!
    var collectionSelectionCompletion: ((String) -> ())!
 
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
    }

    //MARK: - Search
    
    func loadList(searchText: String, type: IABookListType) {
        self.searchText = searchText
        self.type = type
        self.items.removeAllObjects()
        if searchText.stringByReplacingOccurrencesOfString(" ", withString: "") == "" {
            self.collectionView?.reloadData()
        }else {
            loadMore()
        }

    }

    func loadMore() {
        self.addLoadingView()
        switch type {
        case IABookListType.Text?:
            searchManager.searchBooksWithText(searchText!,count: itemsPerPage, offset: self.items.count) { [weak self]books in
                if let mySelf = self {
                    mySelf.items.addObjectsFromArray(books as [AnyObject])
                    mySelf.collectionView?.reloadData()
                    mySelf.removeLoadingView()
                    
                }
            }
            break
        case IABookListType.Creator?:
            searchManager.searchBookOfCreator(searchText!,count: itemsPerPage, offset: self.items.count) { [weak self]books in
                if let mySelf = self {
                    mySelf.items.addObjectsFromArray(books as [AnyObject])
                    mySelf.collectionView?.reloadData()
                    mySelf.removeLoadingView()
                }
            }
            break
        case IABookListType.Collection?:
            searchManager.searchCollectionsAndTexts(searchText!, hidden: false, count: 50, offset: 0) { [weak self] items in
                if let mySelf = self {
                    mySelf.items.addObjectsFromArray(items as [AnyObject])
                    mySelf.collectionView?.reloadData()
                    mySelf.removeLoadingView()
                }
            }
            break
        default:
            break
        }
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
            return cell
        }
    }

    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let item = items[indexPath.row] as! ArchiveItemData
            if item.mediatype == "collection" {
                return Utils.isiPad() ? CGSizeMake(240, 300) : CGSizeMake(self.view.frame.size.width/2-10, 250)
            }else {
                return Utils.isiPad() ? CGSizeMake(235, 394) : CGSizeMake(self.view.frame.size.width/2-10, 300)
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
        self.view.addSubview(activityIndicatorView)
        self.activityIndicatorView.startAnimating()
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraint(NSLayoutConstraint(item: self.activityIndicatorView  , attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
        
        self.view.addConstraint(NSLayoutConstraint(item:  self.activityIndicatorView, attribute: .CenterY, relatedBy: .Equal, toItem:self.view , attribute: .CenterY, multiplier: 1.0, constant: 0))
    }
    
    func removeLoadingView() {
        self.activityIndicatorView.stopAnimating()
        self.activityIndicatorView.removeFromSuperview()
    }
}