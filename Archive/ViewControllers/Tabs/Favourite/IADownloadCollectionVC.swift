//
//  IADownloadCollectionVC.swift
//  Archive
//
//  Created by Islam on 5/12/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import CoreData

class IADownloadCollectionVC: IAGenericItemCollectionVC {
    
    var presentationDelegate = IASortPresentationDelgate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFetchRequest()
    }
    
    // MARK: - CollectionView
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> IAGenericItemCollectionCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
        
        let item = fetchedResultController!.objectAtIndexPath(indexPath) as! ArchiveItem
        
        cell.configure(item, type: .Download) {
            self.showChaptersList(item)
        }
        
        return cell
    }
    
    //MARK: - Show Chapters
    
    func showChaptersList(item: ArchiveItem) {
        let chaptersListVC = self.storyboard?.instantiateViewControllerWithIdentifier("IADownloadedChaptersListVC") as! IADownloadedChaptersListVC
        
        chaptersListVC.chapters = (item.file?.chapters?.allObjects as! [Chapter]).sort({ $0.name < $1.name})
        chaptersListVC.transitioningDelegate = presentationDelegate;
        chaptersListVC.modalPresentationStyle = .Custom
        
        self.presentViewController(chaptersListVC, animated: true) {}
    }
    
    // MARK: - Helpers
    
    func setFetchRequest() {
        let fetchRequest = NSFetchRequest(entityName: "ArchiveItem")
        fetchRequest.predicate = NSPredicate(format: "ANY file.chapters.isDownloaded == YES", argumentArray: nil)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: true)]
        
        setFetchRequest(fetchRequest)
    }

}
