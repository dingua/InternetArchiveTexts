//
//  IAReaderCollectionViewController.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/14/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ReaderCell"
class IAReaderCollectionCellView : UICollectionViewCell {
    
    @IBOutlet weak var pageNumberLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
}

class IAReaderCollectionViewController: UICollectionViewController {
    var imagesDownloader: IABookImagesManager?
    
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
       return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let downloader = imagesDownloader {
            return downloader.numberOfPages!
        } else {
            return 0
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! IAReaderCollectionCellView
        cell.imageView.image = nil
        cell.imageView.af_setImageWithURL(NSURL(string: (self.imagesDownloader?.urlOfPage(indexPath.row,scale: 10))!)!)
        cell.pageNumberLabel.text = "\(indexPath.row)"
        return cell
    }
}
