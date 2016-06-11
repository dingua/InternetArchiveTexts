//
//  IAFavoriteCollectoinVC.swift
//  Archive
//
//  Created by Islam on 5/12/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import CoreData

class IAFavoriteCollectoinVC: IAGenericItemCollectionVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForNotification(Constants.Notification.UserDidLogin.name, action: .userDidLogin)
        setFetchRequest()
        
        if Utils.isLoggedIn() {
            loadData()
        }
    }
    
    // MARK: - CollectionView
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> IAGenericItemCollectionCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
        
        let item = fetchedResultController!.objectAtIndexPath(indexPath) as! ArchiveItem
        
        cell.configure(item, type: .Favorite) {
            IAFavouriteManager.sharedInstance.deleteBookmark(item) { _ in }
        }
        
        cell.secondActionClosure = {
            self.presentDetails(item)
        }
        
        return cell
    }
    
    // MARK: - Helpers
    
    func setFetchRequest() {
        let fetchRequest = NSFetchRequest(entityName: "ArchiveItem")
        fetchRequest.predicate = NSPredicate(format: "isFavourite == YES", argumentArray: nil)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: true)]
        
        setFetchRequest(fetchRequest)
    }
    
    func loadData() {
        let userID = NSUserDefaults.standardUserDefaults().stringForKey("userid")!
        
        addLoadingView()
        IAFavouriteManager.sharedInstance.getBookmarks(userID) {
            self.removeLoadingView()
        }
    }
    
    func userDidLogin() {
        self.loadData()
    }
    
    var bookDetailsPresentationDelegate = IABookDetailsPresentationDelgate()

    func presentDetails(item: ArchiveItem) {
        let bookDetails = UIStoryboard(name: "BookDetails", bundle: nil).instantiateInitialViewController() as! IABookDetailsVC
        bookDetails.book = item
        if Utils.isiPad() {
            bookDetails.transitioningDelegate = self.bookDetailsPresentationDelegate
            bookDetails.modalPresentationStyle = .Custom
            bookDetails.pushListOnDismiss = {text, type in
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
    
    func showReader(item: ArchiveItem, atChapterIndex chapterIndex :Int = -1) {
        let navController = UIStoryboard(name: "Reader",bundle: nil).instantiateInitialViewController() as! UINavigationController
        let bookReader = navController.topViewController as! IAReaderVC
        bookReader.item = item
        bookReader.didGetFileDetailsCompletion = {
            bookReader.setupReaderToChapter(chapterIndex)
        }
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
}

private extension Selector {
    static let userDidLogin = #selector(IAFavoriteCollectoinVC.userDidLogin)
}