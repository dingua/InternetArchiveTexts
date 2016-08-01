//
//  IAGenericItemCollectionCell.swift
//  Archive
//
//  Created by Islam on 5/11/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

public typealias ItemCellCompletionBlock = (() -> ())

class IAGenericItemCollectionCell: UICollectionViewCell {
    
    enum ItemCollectionButtonType: String {
        case None = ""
        case Favorite = "favourite_empty"
        case Download = "download_button"
        case Bookmark = "bookmark_empty"
    }
    
    var buttonType: ItemCollectionButtonType! {
        didSet {
            actionButton.setImage(UIImage(named: buttonType.rawValue), forState: .Normal)
            
            var action: Selector?
            
            switch buttonType! {
            case .None:     action = nil
            case .Favorite: action = .action
            case .Download: action = .action
            case .Bookmark: action = .action
            }
            
            if action != nil {
                actionButton.addTarget(self, action: action!, forControlEvents: .TouchUpInside)
            }
        }
    }
    
    var actionClosure: ItemCellCompletionBlock?
    var secondActionClosure: ItemCellCompletionBlock?
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(item: ArchiveItem, type: ItemCollectionButtonType?, completion: ItemCellCompletionBlock?)->IAGenericItemCollectionCell {
        if type       != nil { buttonType    = type }
        if completion != nil { actionClosure = completion }
        
        titleLabel.text = item.title
        
        if let bookID = item.identifier {
            mainImageView.af_setImageWithURL(Constants.URL.ImageURL(bookID).url)
        }
        
        if buttonType == .Favorite && item.isFavorite {
            actionButton.setImage(UIImage(named: "favourite_filled"), forState: .Normal)
        }
        return self
    }
    

    
    // MARK: - Life Cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        actionButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
        mainImageView.image = nil
    }
    
    // MARK: - Helpers
    
    func action(sender: UIButton) {
        if actionClosure != nil {
            actionClosure!()
        }
    }
    
    @IBAction func secondAction() {
        if secondActionClosure != nil {
            secondActionClosure!()
        }
    }
}

private extension Selector {
    static let action = #selector(IAGenericItemCollectionCell.action(_:))
}