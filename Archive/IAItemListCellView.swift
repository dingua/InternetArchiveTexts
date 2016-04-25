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
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Cell Configuration
    
    func configureWithItem(book: ArchiveItemData) {
        self.bookTitleLabel.text = book.title
        self.bookImageView.image = nil
        self.bookImageView.image = nil
        if let url = NSURL(string: "\(imageBaseURL)\(book.identifier!)") {
            self.bookImageView.af_setImageWithURL(url)
        }
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    func configureWithItem(book: ArchiveItemData,creatorCompletion: (String)->()) {
        self.configureWithItem(book)
    }
    
    func configureWithItem(book: ArchiveItemData,creatorCompletion: (String)->(), collectionCompletion: (String)->()) {
        self.configureWithItem(book ,creatorCompletion: creatorCompletion)
    }
    
}
