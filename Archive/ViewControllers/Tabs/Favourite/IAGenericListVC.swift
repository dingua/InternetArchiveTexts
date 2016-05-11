//
//  IAGenericListVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/6/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import CoreData
import DGActivityIndicatorView

private let reuseIdentifier = "Cell"

class IAGenericListVC: UICollectionViewController, NSFetchedResultsControllerDelegate, IALoadingViewProtocol {

//    let managedContext :NSManagedObjectContext = CoreDataStackManager.sharedManager.managedObjectContext
    
    var fetchRequest: NSFetchRequest = NSFetchRequest()
    
    lazy var fetchedResultController: NSFetchedResultsController = {
        let fetchController =  NSFetchedResultsController(fetchRequest: self.fetchRequest, managedObjectContext: CoreDataStackManager.sharedManager.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchController.delegate = self
        return fetchController
    }()
    var activityIndicatorView : DGActivityIndicatorView?
    
    var blockOperations: [NSBlockOperation] = []
    
    deinit {
        // Cancel all block operations when VC deallocates
        for operation: NSBlockOperation in blockOperations {
            operation.cancel()
        }
        
        blockOperations.removeAll(keepCapacity: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicatorView = DGActivityIndicatorView(type: .ThreeDots, tintColor: UIColor.blackColor())
        
        performFetch()
        
        if Utils.isLoggedIn() {
            loadData()
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IAGenericListVC.userDidLogin), name: notificationUserDidLogin, object: nil)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {}

    func performFetch() {
        do {
            try fetchedResultController.performFetch()
        }catch{}
    }
    func userDidLogin() {}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

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


}
