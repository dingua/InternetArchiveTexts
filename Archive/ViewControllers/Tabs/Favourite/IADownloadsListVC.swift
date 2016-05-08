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
    override func viewDidLoad() {
        fetchRequest = NSFetchRequest(entityName: "Chapter")
        fetchRequest.predicate = NSPredicate(format: "isDownloaded == YES", argumentArray: nil)
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
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
        let chapter = fetchedResultController.objectAtIndexPath(indexPath) as? Chapter
        cell.configureCell(chapter!)
        return cell
    }

    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return Utils.isiPad() ? CGSizeMake(235, 394) : CGSizeMake(min(self.view.frame.size.width/2-10,self.view.frame.size.height/2-10), 300)
    }
    
}
