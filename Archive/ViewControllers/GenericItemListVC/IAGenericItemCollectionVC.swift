//
//  IAGenericItemCollectionVC.swift
//  Archive
//
//  Created by Islam on 5/11/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ItemCell"

class IAGenericItemCollectionVC: UICollectionViewController {
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> IAGenericItemCollectionCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! IAGenericItemCollectionCell
    }
    
}
