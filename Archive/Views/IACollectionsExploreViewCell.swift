//
//  IACollectionsExploreViewCell.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/24/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IACollectionsExploreViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberItemsLabel: UILabel!
    
    //MARK: - Cell Configuration
    func configureWithItem(collection: ArchiveItem) {
        
        self.titleLabel.text = collection.title
        self.imageView.image = nil
        self.imageView.af_setImageWithURL(NSURL(string: "\(imageBaseURL)\(collection.identifier!)")!)
        
        self.imageView.layer.cornerRadius = Utils.isiPad() ? self.imageView.frame.size.width/2 :  50
        self.imageView.clipsToBounds = true
        self.imageView.layer.borderWidth = 1.0
        self.imageView.layer.borderColor = UIColor.blackColor().CGColor
        
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.blackColor().CGColor

    }
}