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
        self.bookImageView.af_setImageWithURL(Constants.URL.ImageURL(book.identifier!).url)
        
        if Utils.isLoggedIn() {
            let imageName = book.isFavorite ? "favourite_filled" : "favourite_empty"
            favouriteBtn.setImage(UIImage(named:imageName), forState: .Normal)
        } else {
            favouriteBtn.setImage(UIImage(named:"favourite_empty"), forState: .Normal)
        }
    }
    
    @IBAction func favouriteBtnPressed(sender: AnyObject) {
        if favoriteClosure != nil {
            favoriteClosure!()
        }
    }
}
