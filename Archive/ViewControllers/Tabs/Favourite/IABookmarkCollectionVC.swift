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
private let reuseIdentifier = "ItemCell"

class IABookmarkVC: IAGenericItemCollectionVC {
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFetchRequest()
    }
    
    
    // MARK: - CollectionView
    
    override func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return  CGSizeMake(300, 250)
    }
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> IABookmarkItemCollectionCell {
        let cell =  collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! IABookmarkItemCollectionCell
        
        fetchedResultController?.managedObjectContext.performBlock {
            let page = self.fetchedResultController!.objectAtIndexPath(indexPath) as! Page
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                cell.configure(page, type: .Bookmark) {
                    IABookmarkManager.sharedInstance.triggerBookmark(IAPage(page: page))
                }
                
                cell.secondActionClosure = {
                    if let item = page.chapter?.file?.archiveItem {
                        self.presentDetails(item)
                    }
                }
            }
        }
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let page = fetchedResultController!.objectAtIndexPath(indexPath) as! Page
        let chapterIndex = (page.chapter?.file?.chapters?.allObjects as! [Chapter]).sort({ $0.name < $1.name}).indexOf(page.chapter!)!
        let number = (page.number?.intValue)!

        showReader(page.chapter!.file!.archiveItem!, atChapterIndex: chapterIndex, atPage: Int(number))
    }
    
    //MARK: - Private
    private func setFetchRequest() {
        let fetchRequest = NSFetchRequest(entityName: "Page")
        fetchRequest.predicate = NSPredicate(format: "isBookmarked == YES", argumentArray: nil)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
        
        setFetchRequest(fetchRequest)
    }
    
    var bookDetailsPresentationDelegate = IABookDetailsPresentationDelgate()

    private func presentDetails(item: ArchiveItem) {
        let bookDetails = UIStoryboard(name: "BookDetails", bundle: nil).instantiateInitialViewController() as! IABookDetailsVC
        bookDetails.book = IAArchiveItem(item: item)
        if Utils.isiPad() {
            bookDetails.transitioningDelegate = self.bookDetailsPresentationDelegate
            bookDetails.modalPresentationStyle = .Custom
            bookDetails.pushListOnDismiss = {text, type in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let itemsListVC = storyboard.instantiateViewControllerWithIdentifier("bookListVC") as! IAItemsListVC
                itemsListVC.loadList(text ?? "", type: type)
                self.navigationController?.pushViewController(itemsListVC, animated: true)
            }
            bookDetails.pushReaderOnChapter = {chapterIndex in
                self.showReader(item, atChapterIndex: chapterIndex)
            }
            self.presentViewController(bookDetails, animated: true, completion: nil)
        }else {
            self.navigationController?.pushViewController(bookDetails, animated: true)
        }
    }
    
    private func showReader(item: ArchiveItem, atChapterIndex chapterIndex :Int = -1, atPage page: Int = 0) {
        let navController = UIStoryboard(name: "Reader",bundle: nil).instantiateInitialViewController() as! UINavigationController
        let bookReader = navController.topViewController as! IAReaderVC
        bookReader.item = IAArchiveItem(item: item)
        bookReader.didGetFileDetailsCompletion = {
            bookReader.setupReaderToChapter(chapterIndex) {
                if page != 0 {
                    bookReader.pageNumber = Int(page)
                    bookReader.updateUIAfterPageSeek(true)
                }
            }
        }
        self.presentViewController(navController, animated: true, completion: nil)
    }


}
