//
//  IAFavouriteListVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/4/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import CoreData
import DGActivityIndicatorView

private let reuseIdentifier = "FavouriteListCell"

class IAFavouriteListVC: IAGenericListVC {
    
    override func viewDidLoad() {
        
        fetchRequest = NSFetchRequest(entityName: "ArchiveItem")
        fetchRequest.predicate = NSPredicate(format: "isFavourite == YES", argumentArray: nil)
        let sortDescriptor = NSSortDescriptor(key: "identifier", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
       
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func loadData() {
        loadBookmarks()
    }
 
    func loadBookmarks() {
        self.addLoadingView()
        IAFavouriteManager.sharedInstance.getBookmarks(NSUserDefaults.standardUserDefaults().stringForKey("userid")!, completion: {_ in
            self.removeLoadingView()
        })
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showReader" {
            let selectedIndex = self.collectionView?.indexPathForCell(sender as! IAItemListCellView)
            let bookReaderNavController = segue.destinationViewController as! UINavigationController
            let bookReader = bookReaderNavController.topViewController as! IAReaderVC
            let item = fetchedResultController.objectAtIndexPath(selectedIndex!) as! ArchiveItem
            bookReader.bookIdentifier = item.identifier!
            bookReader.bookTitle = item.title
            bookReader.item = item
        }
    }
    
    

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return (fetchedResultController.sections?.count)!
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultController.sections![section].numberOfObjects
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! IAItemListCellView
        let item = fetchedResultController.objectAtIndexPath(indexPath) as? ArchiveItem
        cell.configureWithItem(item!)
        cell.favoriteClosure = {
            IAFavouriteManager.sharedInstance.deleteBookmark(item!, completion: {_ in} )
        }
    
        return cell
    }

    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return Utils.isiPad() ? CGSizeMake(235, 394) : CGSizeMake(min(self.view.frame.size.width/2-10,self.view.frame.size.height/2-10), 250)
    }

    //MARK: - Notification
    
    override func userDidLogin() {
        self.loadBookmarks()
    }
}
