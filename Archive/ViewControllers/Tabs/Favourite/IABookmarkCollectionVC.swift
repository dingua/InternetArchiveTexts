//
//  IABookmarkCollectionVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/16/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import CoreData
private let segueReaderIdentifier = "showReader1"

class IABookmarkVC: IAGenericItemCollectionVC {
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFetchRequest()
    }
    
    
    // MARK: - CollectionView
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> IAGenericItemCollectionCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
        
        let page = fetchedResultController!.objectAtIndexPath(indexPath) as! Page
        
        cell.configure(page, type: .Bookmark) {
            IABookmarkManager.sharedInstance.triggerBookmark(IAPage(page: page))
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let page = fetchedResultController!.objectAtIndexPath(indexPath) as! Page
        let navController = UIStoryboard(name: "Reader", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let bookReader = navController.topViewController as! IAReaderVC
        bookReader.item = IAArchiveItem(item: page.chapter!.file!.archiveItem!)
        bookReader.didGetFileDetailsCompletion = {
            let chapterIndex = (page.chapter?.file?.chapters?.allObjects as! [Chapter]).sort({ $0.name < $1.name}).indexOf(page.chapter!)!
            bookReader.setupReaderToChapter(chapterIndex){
                let number = (page.number?.intValue)!
                if number != 0 {
                    bookReader.pageNumber = Int(number)
                    bookReader.updateUIAfterPageSeek(true)
                }
            }
        }
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    //MARK: - Private
    private func setFetchRequest() {
        let fetchRequest = NSFetchRequest(entityName: "Page")
        fetchRequest.predicate = NSPredicate(format: "isBookmarked == YES", argumentArray: nil)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
        
        setFetchRequest(fetchRequest)
    }
}
