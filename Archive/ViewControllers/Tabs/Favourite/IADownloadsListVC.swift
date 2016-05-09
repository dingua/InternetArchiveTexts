//
//  IADownloadVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/6/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "DownloadListCell"

class IADownloadsListVC: IAGenericListVC {
    var presentationDelegate =  IASortPresentationDelgate()

    
    override func viewDidLoad() {
        fetchRequest = NSFetchRequest(entityName: "ArchiveItem")
        fetchRequest.predicate = NSPredicate(format: "ANY file.chapters.isDownloaded == YES", argumentArray: nil)
        let sortDescriptor = NSSortDescriptor(key: "identifier", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return (fetchedResultController.sections?.count)!
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultController.sections![section].numberOfObjects
    }


    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! IADownloadListCollectionViewCell
        let archiveItem = fetchedResultController.objectAtIndexPath(indexPath) as? ArchiveItem
        cell.configureCell(archiveItem!, downloadCompletion: {
            self.showChaptersList(archiveItem!)
        })
        return cell
    }

    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return Utils.isiPad() ? CGSizeMake(235, 394) : CGSizeMake(min(self.view.frame.size.width/2-10,self.view.frame.size.height/2-10), 300)
    }
    
    //MARK: - Show CHapters
    
    func showChaptersList(item: ArchiveItem) {
        let chaptersListVC = self.storyboard?.instantiateViewControllerWithIdentifier("IADownloadedChaptersListVC") as! IADownloadedChaptersListVC
        chaptersListVC.transitioningDelegate = presentationDelegate;
        chaptersListVC.chapters = (item.file?.chapters?.allObjects as! [Chapter]).sort({ $0.name < $1.name})
        chaptersListVC.modalPresentationStyle = .Custom
        self.presentViewController(chaptersListVC, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showReader" {
            let selectedIndex = self.collectionView?.indexPathForCell(sender as! IADownloadListCollectionViewCell)
            let bookReaderNavController = segue.destinationViewController as! UINavigationController
            let bookReader = bookReaderNavController.topViewController as! IAReaderVC
            let item = fetchedResultController.objectAtIndexPath(selectedIndex!) as! ArchiveItem
            bookReader.bookIdentifier = item.identifier!
            bookReader.bookTitle = item.title
            bookReader.item = ArchiveItemData(item: item)
        }
    }

    
}
