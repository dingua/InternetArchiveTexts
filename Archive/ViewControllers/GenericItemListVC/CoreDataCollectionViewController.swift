//
//  IACoreDataCollectionViewController.swift
//  Archive
//
//  Created by Islam on 5/12/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import CoreData

class CoreDataCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    var blockOperations = [NSBlockOperation]()
    
    var fetchedResultController: NSFetchedResultsController? {
        didSet {
            fetchedResultController!.delegate = self
            performFetch()
        }
    }
    
    func performFetch() {
        do {
            try fetchedResultController!.performFetch()
        }
        catch let error as NSError {
            print("Error performFetch(): \(error.localizedDescription)")
        }
        
        collectionView?.reloadData()
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return fetchedResultController?.sections?.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultController?.sections?[section].numberOfObjects ?? 0
    }
    
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        blockOperations.removeAll(keepCapacity: false)
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        // Using 'unowned' here because if the controller DID change that means self != nil
        
        let batchUpdate = { [unowned self] in self.blockOperations.forEach({ $0.start() }) }
        
        collectionView!.performBatchUpdates(batchUpdate) { [unowned self] _ in
            self.blockOperations.removeAll(keepCapacity: false)
        }
    }
    
    
    func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                                    atIndexPath indexPath: NSIndexPath?,
                                                forChangeType type: NSFetchedResultsChangeType,
                                                              newIndexPath: NSIndexPath?)
    {
        switch type {
        case .Insert:
            print("Insert Object: \(newIndexPath)")
            
            blockOperations.append(NSBlockOperation() { [weak self] in
                self?.collectionView?.insertItemsAtIndexPaths([newIndexPath!])
                }
            )
        case .Delete:
            print("Delete Object: \(indexPath)")
            
            blockOperations.append(NSBlockOperation() { [weak self] in
                self?.collectionView?.deleteItemsAtIndexPaths([indexPath!])
                }
            )
        case .Move:
            print("Move Object: \(indexPath) to \(newIndexPath)")
            
            blockOperations.append(NSBlockOperation() { [weak self] in
                self?.collectionView?.moveItemAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
                }
            )
        case .Update:
            print("Update Object: \(indexPath)")
            
            blockOperations.append(NSBlockOperation() { [weak self] in
                self?.collectionView?.reloadItemsAtIndexPaths([indexPath!])
                }
            )
        }
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
                                     atIndex sectionIndex: Int,
                                             forChangeType type: NSFetchedResultsChangeType)
    {
        switch type {
        case .Insert:
            print("Insert Section: \(sectionIndex)")
            
            blockOperations.append(NSBlockOperation() { [weak self] in
                self?.collectionView?.insertSections(NSIndexSet(index: sectionIndex))
                }
            )
        case .Delete:
            print("Delete Section: \(sectionIndex)")
            
            blockOperations.append(NSBlockOperation() { [weak self] in
                self?.collectionView?.deleteSections(NSIndexSet(index: sectionIndex))
                }
            )
        case .Update:
            print("Update Section: \(sectionIndex)")
            
            blockOperations.append(NSBlockOperation() { [weak self] in
                self?.collectionView?.reloadSections(NSIndexSet(index: sectionIndex))
                }
            )
        case .Move:
            break
        }
    }
    
}
