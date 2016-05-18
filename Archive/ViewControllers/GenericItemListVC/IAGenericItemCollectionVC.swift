//
//  IAGenericItemCollectionVC.swift
//  Archive
//
//  Created by Islam on 5/11/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import CoreData
import DGActivityIndicatorView

private let reuseIdentifier = "ItemCell"
private let segueReaderIdentifier = "showReader"

class IAGenericItemCollectionVC: CoreDataCollectionViewController, IALoadingViewProtocol {
    
    var activityIndicatorView : DGActivityIndicatorView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView = DGActivityIndicatorView(type: .ThreeDots, tintColor: UIColor.blackColor())
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> IAGenericItemCollectionCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! IAGenericItemCollectionCell
    }
    
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return Utils.isiPad() ? CGSizeMake(150, 250) : CGSizeMake(100, 135)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueReaderIdentifier {
            let indexPath = collectionView?.indexPathForCell(sender as! IAGenericItemCollectionCell)
            let item = fetchedResultController!.objectAtIndexPath(indexPath!) as! ArchiveItem
            
            let navController = segue.destinationViewController as! UINavigationController
            let bookReader = navController.topViewController as! IAReaderVC
            bookReader.bookIdentifier = item.identifier!
            bookReader.bookTitle = item.title
            bookReader.item = item
        }
    }
    
    // MARK: - Fetched Results Controller
    
    func setFetchRequest(fetchRequest: NSFetchRequest) {
        fetchedResultController = {
            let context = CoreDataStackManager.sharedManager.managedObjectContext
            
            return NSFetchedResultsController(fetchRequest: fetchRequest,
                                              managedObjectContext: context,
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
            }()
    }
    
}
