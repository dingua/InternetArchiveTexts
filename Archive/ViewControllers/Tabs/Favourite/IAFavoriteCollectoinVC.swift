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
        
        registerForNotification(notificationUserDidLogin, action: .userDidLogin)
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
            IABookmarkManager.sharedInstance.deleteBookmark(item) { _ in }
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
        IABookmarkManager.sharedInstance.getBookmarks(userID) {
            self.removeLoadingView()
        }
    }
    
    func userDidLogin() {
        self.loadData()
    }
    
}

private extension Selector {
    static let userDidLogin = #selector(IAFavoriteCollectoinVC.userDidLogin)
}