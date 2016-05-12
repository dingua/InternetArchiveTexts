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
    }
    
    var buttonType: ItemCollectionButtonType! {
        didSet {
            actionButton.setImage(UIImage(named: buttonType.rawValue), forState: .Normal)
            
            var action: Selector?
            
            switch buttonType! {
            case .None:     action = nil
            case .Favorite: action = .action
            case .Download: action = .action
            }
            
            if action != nil {
                actionButton.addTarget(self, action: action!, forControlEvents: .TouchUpInside)
            }
        }
    }
    
    var actionClosure: ItemCellCompletionBlock?
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(item: ArchiveItem, type: ItemCollectionButtonType?, completion: ItemCellCompletionBlock?) {
        if type       != nil { buttonType    = type }
        if completion != nil { actionClosure = completion }
        
        if let bookID = item.identifier {
            mainImageView.af_setImageWithURL(Constants.ImageURL(bookID))
        }
        
        if buttonType == .Favorite && item.isFavorite {
            actionButton.setImage(UIImage(named: "favourite_filled"), forState: .Normal)
            
            if item.isFavorite {
                
            }
        }
    }
    
    // MARK: - Life Cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        actionButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
    }
    
    // MARK: - Helpers
    
    func action(sender: UIButton) {
        if actionClosure != nil {
            actionClosure!()
        }
    }
    
}

private extension Selector {
    static let action = #selector(IAGenericItemCollectionCell.action(_:))
}