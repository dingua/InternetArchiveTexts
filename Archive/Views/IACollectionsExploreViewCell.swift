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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configureWithItem(collection: ArchiveItem) {
        titleLabel.text = collection.title
        
        imageView.af_setImageWithURL(Constants.URL.ImageURL(collection.identifier!).url)
        
        imageView.layer.cornerRadius = Utils.isiPad() ? imageView.frame.size.width/2 :  50
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.blackColor().CGColor
    }
}