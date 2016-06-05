//
//  IACollectionsExploreVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/24/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

private let reuseIdentifier = "collectionExploreCell"

class IACollectionsExploreVC: UICollectionViewController, IARootVCProtocol {
    
    var searchManager = IAItemsManager()
    var collections = [ArchiveItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchCollections()
        print("downloaded chapters \(IADownloadsManager.sharedInstance.getDownloadedChapters())")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationItem()
    }
    //MARK: - Helpers
    
    func searchCollections() {
        searchManager.searchCollections("texts", hidden: true, count: 50, page: 0) { [weak self] collections  in
            if let mySelf = self {
                let allTextsDictionary = [
                    "identifier": "texts",
                    "title": "All Texts"
                ]
                let group = dispatch_group_create()
                do {
                    let managedCtx = try CoreDataStackManager.sharedManager.createPrivateQueueContext()
                    dispatch_group_enter(group)
                    managedCtx.performBlock {
                        mySelf.collections.append(ArchiveItem.createArchiveItem(allTextsDictionary, managedObjectContext: managedCtx, temporary: true)!)
                        dispatch_group_leave(group)
                    }
                
                }catch{
                    mySelf.collections.appendContentsOf(collections)
                    mySelf.collectionView!.reloadData()
                }
                dispatch_group_notify(group, dispatch_get_main_queue(), {
                    mySelf.collections.appendContentsOf(collections)
                    mySelf.collectionView!.reloadData()
                })
             }
        }
    }
    
    
    // MARK: - UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return Utils.isiPad() ? CGSizeMake(240, 300) : CGSizeMake(self.view.frame.size.width/2-10, 250)
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collections.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! IACollectionsExploreViewCell
        cell.configureWithItem(collections[indexPath.row])
        return cell
    }
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCollectionItems" {
            let selectedIndex = self.collectionView?.indexPathForCell(sender as! IACollectionsExploreViewCell)
            let vc  = segue.destinationViewController as! IAItemsListVC
            let collectionData = collections[selectedIndex!.row]
            vc.loadList(collectionData.identifier!, type: .Collection)
            vc.title = collectionData.title
        }
    }
    
    //MARK: - IARootVCProtocol
    
    func logoutAction() {
        logout()
    }

}