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
            let chaptersBookmarksVC =  UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("IAChapterBookmarkExploreVC") as! IAChapterBookmarkExploreVC
            chaptersBookmarksVC.transitioningDelegate = presentationDelegate
            chaptersBookmarksVC.item = item
            chaptersBookmarksVC.chapterSelectionHandler = { chapterIndex in
                self.showReader(item, atChapterIndex: chapterIndex)
            }
            chaptersBookmarksVC.bookmarkSelectionHandler = { page in
                self.showReader(item, atPage: page)
            }
            chaptersBookmarksVC.modalPresentationStyle = .Custom
            self.presentViewController(chaptersBookmarksVC, animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    func setFetchRequest() {
        let fetchRequest = NSFetchRequest(entityName: "ArchiveItem")
        fetchRequest.predicate = NSPredicate(format: "ANY file.chapters.isDownloaded == YES", argumentArray: nil)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: true)]
        
        setFetchRequest(fetchRequest)
    }
    
    func showReader(item: ArchiveItem, atChapterIndex chapterIndex :Int = -1) {
        
        let navController = UIStoryboard(name: "Reader",bundle: nil).instantiateInitialViewController() as! UINavigationController
        let bookReader = navController.topViewController as! IAReaderVC
        bookReader.bookIdentifier = item.identifier!
        bookReader.bookTitle = item.title
        bookReader.item = item
        bookReader.didGetFileDetailsCompletion = {
            bookReader.setupReaderToChapter(chapterIndex)
        }
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    func showReader(item: ArchiveItem, atPage page :Page) {
        
        let navController = UIStoryboard(name: "Reader",bundle: nil).instantiateInitialViewController() as! UINavigationController
        let bookReader = navController.topViewController as! IAReaderVC
        bookReader.bookIdentifier = item.identifier!
        bookReader.bookTitle = item.title
        bookReader.item = item
        bookReader.didGetFileDetailsCompletion = {
            bookReader.setupReaderToChapter((item.file?.chapters?.allObjects as! [Chapter]).sort({ $0.name < $1.name}).indexOf(page.chapter!)!){
                bookReader.pageNumber = Int((page.number?.intValue)!)
                bookReader.updateUIAfterPageSeek(true)
            }
        }
        self.presentViewController(navController, animated: true, completion: nil)
    }

}
