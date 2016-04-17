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
    @IBOutlet weak var creatorButton: UIButton!
    @IBOutlet weak var creatorTitleLabel: UILabel!
    @IBOutlet weak var collectionImageView: UIImageView!
    @IBOutlet weak var collectionButton: UIButton!
    var creatorCompletion: (String)->()?
    var collectionCompletion: (String)->()?
    
    var creatorName: String?
    var collectionName: String?
    
    //MARK: - Init
    override init(frame: CGRect) {
        self.creatorCompletion = {creator ->() in }
        self.collectionCompletion = {collection ->() in }
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.creatorCompletion = {creator ->() in }
        self.collectionCompletion = {collection ->() in }
        super.init(coder: aDecoder)
    }
    
    //MARK: - Cell Configuration
    
    func configureWithItem(book: ArchiveItemData) {
        self.bookTitleLabel.text = book.title
        self.bookImageView.image = nil
        self.creatorButton.setTitle(book.creator, forState: .Normal)
        self.creatorName = book.creator
        self.collectionName = book.collections?.firstObject as? String
        self.creatorButton.addTarget(self, action: #selector(IAItemListCellView.creatorButtonPressed), forControlEvents: .TouchUpInside)
        
        self.collectionButton.setTitle(book.collections?.firstObject as? String, forState: .Normal)
        self.collectionButton.addTarget(self, action: #selector(IAItemListCellView.collectionButtonPressed), forControlEvents: .TouchUpInside)
        
        self.bookImageView.image = nil
        if let url = NSURL(string: "\(imageBaseURL)\(book.identifier!)") {
            self.bookImageView.af_setImageWithURL(url)
        }
        
        self.collectionImageView.image = nil
        if let url = NSURL(string: "\(imageBaseURL)\(book.collections?.firstObject as! String)") {
            self.collectionImageView.af_setImageWithURL(url)
        }
        self.collectionImageView.layer.cornerRadius = Utils.isiPad() ? self.collectionImageView.frame.size.width/2 :  25
        self.collectionImageView.clipsToBounds = true
        self.collectionImageView.layer.borderWidth = 1.0
        self.collectionImageView.layer.borderColor = UIColor.blackColor().CGColor
        
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    func configureWithItem(book: ArchiveItemData,creatorCompletion: (String)->()) {
        self.configureWithItem(book)
        self.creatorCompletion = creatorCompletion
    }
    
    func configureWithItem(book: ArchiveItemData,creatorCompletion: (String)->(), collectionCompletion: (String)->()) {
        self.configureWithItem(book ,creatorCompletion: creatorCompletion)
        self.collectionCompletion = collectionCompletion
    }
    
    //MARK: - IBACTION
    
    func creatorButtonPressed() {
        if let name = creatorName {
            self.creatorCompletion(name)
        }
    }
    
    func collectionButtonPressed() {
        if let name = collectionName {
            self.collectionCompletion(name)
        }
    }
}
