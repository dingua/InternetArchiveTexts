//
//  IAItemListCellView.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/24/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IAItemListCellView : UICollectionViewCell {
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var favouriteBtn: UIButton!
    
    var favoriteClosure: (()->())?
    
    override func prepareForReuse() {
        bookImageView.image = nil
    }
    
    //MARK: - Cell Configuration
    
    func configureWithItem(book: ArchiveItem) {
        self.bookTitleLabel.text = book.title
        if !Utils.isiPad() {
            self.bookTitleLabel.font = UIFont(name: self.bookTitleLabel.font!.fontName, size: 12)
        }
        self.bookImageView.af_setImageWithURL(Constants.ImageURL(book.identifier!))
        
        if Utils.isLoggedIn() {
            let imageName = book.isFavorite ? "favourite_filled" : "favourite_empty"
            favouriteBtn.setImage(UIImage(named:imageName), forState: .Normal)
        } else {
            favouriteBtn.hidden = true
        }
        
//        contentView.layer.borderWidth = 1.0
//        contentView.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    @IBAction func favouriteBtnPressed(sender: AnyObject) {
        if favoriteClosure != nil {
            favoriteClosure!()
        }
    }
}
