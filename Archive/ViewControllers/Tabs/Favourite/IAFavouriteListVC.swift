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

class IAFavouriteListVC: UICollectionViewController, NSFetchedResultsControllerDelegate, IALoadingViewProtocol {

    let managedContext :NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    let fetchRequest: NSFetchRequest  = {
        let fetch = NSFetchRequest(entityName: "ArchiveItem")
        fetch.predicate = NSPredicate(format: "isFavourite == YES", argumentArray: nil)
        let sortDescriptor = NSSortDescriptor(key: "identifier", ascending: true)
        fetch.sortDescriptors = [sortDescriptor]
        return fetch
    }()
    
    lazy var fetchedResultController: NSFetchedResultsController = {
        let fetchController =  NSFetchedResultsController(fetchRequest: self.fetchRequest, managedObjectContext: self.managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchController.delegate = self
        return fetchController
    }()
    
    var blockOperations: [NSBlockOperation] = []

    deinit {
        // Cancel all block operations when VC deallocates
        for operation: NSBlockOperation in blockOperations {
            operation.cancel()
        }
        
        blockOperations.removeAll(keepCapacity: false)
    }
    
    var activityIndicatorView : DGActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorView = DGActivityIndicatorView(type: .ThreeDots, tintColor: UIColor.blackColor())
       
        performFetch()
        
        if Utils.isLoggedIn() {
            loadBookmarks()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IAFavoritesVC.userDidLogin), name: notificationUserDidLogin, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadBookmarks() {
        self.addLoadingView()
        IABookmarkManager.sharedInstance.getBookmarks(NSUserDefaults.standardUserDefaults().stringForKey("userid")!, completion: {_ in
            self.removeLoadingView()
        })
        
    }
    
    func performFetch() {
        do {
            try fetchedResultController.performFetch()
        }catch{}
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
            bookReader.item = ArchiveItemData(item: item)
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
        cell.configureWithArchiveItem(item!)
        cell.favouriteSelectionCompletion = {
            IABookmarkManager.sharedInstance.deleteBookmark(item!.identifier!, completion: {_ in} )
        }
    
        return cell
    }

    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        blockOperations.removeAll(keepCapacity: false)
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        if type == NSFetchedResultsChangeType.Insert {
            print("Insert Object: \(newIndexPath)")
            
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertItemsAtIndexPaths([newIndexPath!])
                    }
                    })
            )
        }
        else if type == NSFetchedResultsChangeType.Update {
            print("Update Object: \(indexPath)")
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadItemsAtIndexPaths([indexPath!])
                    }
                    })
            )
        }
        else if type == NSFetchedResultsChangeType.Move {
            print("Move Object: \(indexPath)")
            
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.moveItemAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
                    }
                    })
            )
        }
        else if type == NSFetchedResultsChangeType.Delete {
            print("Delete Object: \(indexPath)")
            
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteItemsAtIndexPaths([indexPath!])
                    }
                    })
            )
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        if type == NSFetchedResultsChangeType.Insert {
            print("Insert Section: \(sectionIndex)")
            
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertSections(NSIndexSet(index: sectionIndex))
                    }
                    })
            )
        }
        else if type == NSFetchedResultsChangeType.Update {
            print("Update Section: \(sectionIndex)")
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadSections(NSIndexSet(index: sectionIndex))
                    }
                    })
            )
        }
        else if type == NSFetchedResultsChangeType.Delete {
            print("Delete Section: \(sectionIndex)")
            
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteSections(NSIndexSet(index: sectionIndex))
                    }
                    })
            )
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView!.performBatchUpdates({ () -> Void in
            for operation: NSBlockOperation in self.blockOperations {
                operation.start()
            }
            }, completion: { (finished) -> Void in
                self.blockOperations.removeAll(keepCapacity: false)
        })
    }

    //MARK: - Notification
    
    func userDidLogin() {
        self.loadBookmarks()
    }
}
